/*
 * Copyright 2017 Marcus Soll
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "databasetools.h"

#include <QDate>

bool DatabaseTools::create_new_db()
{
    DEBUG("Creating database");

    QSqlQuery query(database);

    QStringList operations;
    operations.append("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT)");
    operations.append("CREATE TABLE language (rowid INTEGER PRIMARY KEY, language TEXT)");
    operations.append("INSERT INTO language (rowid, language) VALUES (1, 'Default')");
    operations.append("CREATE TABLE vocabulary (rowid INTEGER PRIMARY KEY, word TEXT, translation TEXT, priority INT, creation INT, modification INT, language INT, FOREIGN KEY(language) REFERENCES language(rowid))");
    operations.append("CREATE INDEX index_vocabulary_language ON vocabulary(language)");
    operations.append("CREATE INDEX index_vocabulary_creation ON vocabulary(creation)");
    operations.append("CREATE INDEX index_vocabulary_modification ON vocabulary(modification)");
    operations.append("INSERT INTO meta (key, value) VALUES ('version', '4')");

    foreach(QString s, operations)
    {
        if(!query.exec(s))
        {
            QString error = s;
            error.append(": ").append(query.lastError().text());
            CRITICAL(error);
            return false;
        }
    }

    return true;
}

bool DatabaseTools::test_and_update_db()
{
    QSqlQuery query(database);
    QString s = QString("SELECT value FROM meta WHERE key='version'");

    if(!query.exec(s))
    {
        QString error = s;
        error.append(": ").append(query.lastError().text());
        CRITICAL(error);
        return false;
    }
    if(!query.isSelect())
    {
        QString error = s;
        error.append(": No SELECT");
        CRITICAL(error);
        return false;
    }
    if(!query.next())
    {
        WARNING("No metadata 'version'");
        return false;
    }

    switch(query.value(0).toInt())
    {
    // Upgrade settings
    case 1:
        DEBUG("Database upgrade: 1 -> 2");
        /*
         * This database update simplifies all words contained in the database.
         * It is needed because the old CSV import did not simplify.
         */
        {
            QStringList to_update;

            s = "SELECT word FROM vocabulary";

            query.clear();
            query.prepare(s);

            if(!query.exec())
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }
            if(!query.isSelect())
            {
                QString error = s;
                error.append(": No select");
                WARNING(error);
                return false;
            }

            while(query.next())
            {
                QString word = query.value(0).toString();
                if(word.simplified() != word)
                {
                    to_update << word;
                }
            }

            for(QStringList::iterator i = to_update.begin(); i != to_update.end(); ++i)
            {
                s = "UPDATE OR IGNORE vocabulary SET word=:new WHERE word=:old";

                query.clear();
                query.prepare(s);
                query.bindValue(":new", (*i).simplified());
                query.bindValue(":old", *i);

                if(!query.exec())
                {
                    QString error = s;
                    error.append(": ").append(query.lastError().text());
                    WARNING(error);
                }
            }

            query.clear();
            s = "UPDATE meta SET value=2 WHERE key='version'";

            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                CRITICAL(error);
                return false;
            }
        }
        DEBUG("Upgrade complete");

    case 2:
        /*
         * Move to new database format
         */
        DEBUG("Database upgrade: 2 -> 3");
        {

            std::vector<QString> words;
            std::vector<QString> translation;
            std::vector<int> priority;

            // At first fetch all vocabulary

            query.clear();
            s = "SELECT word, translation, priority FROM vocabulary";

            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }
            if(!query.isSelect())
            {
                QString error = s;
                error.append(": No select");
                WARNING(error);
                return false;
            }

            while(query.next())
            {
                words.emplace_back(query.value(0).toString());
                translation.emplace_back(query.value(1).toString());
                priority.emplace_back(query.value(2).toInt());
            }

            // Now update db schema

            s = "DROP TABLE vocabulary";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE TABLE language (language TEXT)";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "INSERT INTO language (rowid, language) VALUES (1, 'Default')";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE TABLE vocabulary (word TEXT, translation TEXT, priority INT, creation INT, modification INT, language INT, FOREIGN KEY(language) REFERENCES language(rowid))";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "UPDATE meta SET value='3' WHERE key='version'";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            // Insert vocabulary back to db
            database.transaction();
            qint64 date = QDate::currentDate().toJulianDay();
            s = "INSERT INTO vocabulary (word, translation, priority, creation, modification, language) VALUES (:word, :translation, :priority, :creation, :modification, :language)";

            for(size_t index = 0; index < words.size(); ++index)
            {
                query.prepare(s);
                query.bindValue(":word", words[index]);
                query.bindValue(":translation", translation[index]);
                query.bindValue(":priority", priority[index]);
                query.bindValue(":creation", date);
                query.bindValue(":modification", date);
                query.bindValue(":language", 1);

                if(!query.exec())
                {
                    QString error = s;
                    error.append(": ").append(query.lastError().text());
                    WARNING(error);
                    database.rollback();
                    return false;
                }
            }
            database.commit();
        }
        DEBUG("Upgrade complete");

    case 3:
        /*
         * Added indices
         *
         * Use explicit rowid
         * https://sqlite.org/foreignkeys.html
         */
        DEBUG("Database upgrade: 3 -> 4");
        {
            std::vector<QString> v_words;
            std::vector<QString> v_translation;
            std::vector<int> v_priority;
            std::vector<qlonglong> v_creation;
            std::vector<qlonglong> v_modification;
            std::vector<int> v_language;

            std::vector<int> l_rowid;
            std::vector<QString> l_language;

            // Fetch all vocabulary

            query.clear();
            s = "SELECT word,translation,priority,creation,modification,language FROM vocabulary";

            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }
            if(!query.isSelect())
            {
                QString error = s;
                error.append(": No select");
                WARNING(error);
                return false;
            }

            while(query.next())
            {
                v_words.emplace_back(query.value(0).toString());
                v_translation.emplace_back(query.value(1).toString());
                v_priority.emplace_back(query.value(2).toInt());
                v_creation.emplace_back(query.value(3).toLongLong());
                v_modification.emplace_back(query.value(4).toLongLong());
                v_language.emplace_back(query.value(5).toInt());
            }

            // Fetch all languages

            query.clear();
            s = "SELECT rowid,language FROM language";

            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }
            if(!query.isSelect())
            {
                QString error = s;
                error.append(": No select");
                WARNING(error);
                return false;
            }

            while(query.next())
            {
                l_rowid.emplace_back(query.value(0).toInt());
                l_language.emplace_back(query.value(1).toString());
            }

            // Now update db schema

            s = "DROP TABLE vocabulary";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "DROP TABLE language";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE TABLE language (rowid INTEGER PRIMARY KEY, language TEXT)";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE TABLE vocabulary (rowid INTEGER PRIMARY KEY, word TEXT, translation TEXT, priority INT, creation INT, modification INT, language INT, FOREIGN KEY(language) REFERENCES language(rowid))";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE INDEX index_vocabulary_language ON vocabulary(language)";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE INDEX index_vocabulary_creation ON vocabulary(creation)";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE INDEX index_vocabulary_modification ON vocabulary(modification)";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "UPDATE meta SET value='4' WHERE key='version'";
            if(!query.exec(s))
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            database.transaction();
            // Insert languages back into db
            s = "INSERT INTO language (rowid, language) VALUES (:rowid, :language)";
            for(size_t index = 0; index < l_rowid.size(); ++index)
            {
                query.prepare(s);
                query.bindValue(":rowid", l_rowid[index]);
                query.bindValue(":language", l_language[index]);
                if(!query.exec())
                {
                    QString error = s;
                    error.append(": ").append(query.lastError().text());
                    WARNING(error);
                    database.rollback();
                    return false;
                }
            }

            // Insert vocabulary back to db
            s = "INSERT INTO vocabulary (word, translation, priority, creation, modification, language) VALUES (:word, :translation, :priority, :creation, :modification, :language)";

            for(size_t index = 0; index < v_words.size(); ++index)
            {
                query.prepare(s);
                query.bindValue(":word", v_words[index]);
                query.bindValue(":translation", v_translation[index]);
                query.bindValue(":priority", v_priority[index]);
                query.bindValue(":creation", v_creation[index]);
                query.bindValue(":modification", v_modification[index]);
                query.bindValue(":language", v_language[index]);

                if(!query.exec())
                {
                    QString error = s;
                    error.append(": ").append(query.lastError().text());
                    WARNING(error);
                    database.rollback();
                    return false;
                }
            }
            database.commit();

            // Clean database - no hard failure!
            s = "VACUUM";
            if(!query.exec())
            {
                QString error = s;
                error.append(": ").append(query.lastError().text());
                WARNING(error);
            }

        }
        DEBUG("Upgrade complete");

    case 4:
        DEBUG("Database version: 4");
        return true;
        break;

    default:
        /* Safeguard - if we reach this point something went REALLY wrong
         */
        WARNING("Unknown database version");
        return false;
        break;
    }
}
