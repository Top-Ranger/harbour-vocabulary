#include "databasetools.h"

#include <QDate>

bool DatabaseTools::create_new_db()
{
    DEBUG("Creating database");

    QSqlQuery query(database);

    QStringList operations;
    operations.append("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT)");
    operations.append("CREATE TABLE language (language TEXT)");
    operations.append("INSERT INTO language (rowid, language) VALUES (1, 'Default')");
    operations.append("CREATE TABLE vocabulary (word TEXT, translation TEXT, priority INT, creation INT, modification INT, language INT, FOREIGN KEY(language) REFERENCES language(rowid))");
    operations.append("INSERT INTO meta VALUES ('version', '3')");

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
        DEBUG("Database version: 3");
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
