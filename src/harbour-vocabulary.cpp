#include <QCoreApplication>
#include <QCoreApplication>
/*
 * Copyright 2016,2017 Marcus Soll
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

#include "global.h"

#include "randomvocabulary.h"
#include "simpleinterface.h"
#include "trainer.h"
#include "settingsproxy.h"
#include "fileutils.h"
#include "csvhandle.h"

#include <QtQuick>
#include <sailfishapp.h>
#include <QtQml>
#include <vector>
#include <QCoreApplication>
#include <QStandardPaths>

bool create_new_db();
bool test_and_update_db();

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("harbour-vocabulary");
    QCoreApplication::setApplicationName("harbour-vocabulary");

    // Register QML types
    qmlRegisterType<Trainer>("harbour.vocabulary.Trainer", 1, 0, "Trainer");
    qmlRegisterType<SettingsProxy>("harbour.vocabulary.SettingsProxy", 1, 0, "SettingsProxy");
    qmlRegisterType<CSVHandle>("harbour.vocabulary.CSVHandle", 1, 0, "CSVHandle");

    // Connect to DB
    QString path = QString(QStandardPaths::writableLocation(QStandardPaths::DataLocation));
    QDir dir(path);

    if(!dir.exists())
    {
        DEBUG("Creating directory" << path);
        dir.mkpath(path);
    }

    path.append("/database.sqlite3");
    QFile file(path);
    bool exists = file.exists();

    database.setDatabaseName(path);
    if(!database.open())
    {
        DEBUG(database.lastError().text());
        FATAL("Can not open database.sqlite3");
    }

    if(!exists)
    {
        if(!create_new_db())
        {
            database.close();
            file.remove();
            FATAL("Can't create database.sqlite3");
        }
    }
    else
    {
        if(!test_and_update_db())
        {
            database.close();
            file.remove();
            FATAL("Can't read/update database.sqlite3");
        }
    }

    // Add classes to QQuickView
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    RandomVocabulary random_vocabulary;
    SimpleInterface simple_interface;
    FileUtils file_utils;

    view->rootContext()->setContextProperty("random_vocabulary", &random_vocabulary);
    view->rootContext()->setContextProperty("simple_interface", &simple_interface);
    view->rootContext()->setContextProperty("file_utils", &file_utils);

    // Start application
    view->setSource(SailfishApp::pathTo("qml/harbour-vocabulary.qml"));
    view->show();

    int return_value = app->exec();
    database.close();
    return return_value;
}

bool create_new_db()
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
            QString error = s.append(": ").append(query.lastError().text());
            CRITICAL(error);
            return false;
        }
    }

    return true;
}

bool test_and_update_db()
{
    QSqlQuery query(database);
    QString s = QString("SELECT value FROM meta WHERE key='version'");

    if(!query.exec(s))
    {
        QString error = s.append(": ").append(query.lastError().text());
        CRITICAL(error);
        return false;
    }
    if(!query.isSelect())
    {
        QString error = s.append(": No SELECT");
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
                QString error = s.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }
            if(!query.isSelect())
            {
                QString error = s.append(": No select");
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
                    QString error = s.append(": ").append(query.lastError().text());
                    WARNING(error);
                }
            }

            query.clear();
            s = "UPDATE meta SET value=2 WHERE key='version'";

            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
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
                words.push_back(query.value(0).toString());
                translation.push_back(query.value(1).toString());
                priority.push_back(query.value(2).toInt());
            }

            // Now update db schema

            s = "DROP TABLE vocabulary";
            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE TABLE language (language TEXT)";
            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "INSERT INTO language (rowid, language) VALUES (1, 'Default')";
            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "CREATE TABLE vocabulary (word TEXT, translation TEXT, priority INT, creation INT, modification INT, language INT, FOREIGN KEY(language) REFERENCES language(rowid))";
            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
                WARNING(error);
                return false;
            }

            s = "UPDATE meta SET value='3' WHERE key='version'";
            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
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
