/*
 * Copyright 2016 Marcus Soll
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

#include <QtQuick>
#include <sailfishapp.h>

bool create_new_db();
bool test_and_update_db();

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("harbour-vocabulary");
    QCoreApplication::setApplicationName("harbour-vocabulary");

    // Register QML types
    qmlRegisterType<Trainer>("harbour.vocabulary.Trainer", 1, 0, "Trainer");
    qmlRegisterType<SettingsProxy>("harbour.vocabulary.SettingsProxy", 1, 0, "SettingsProxy");

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
    QGuiApplication *app = SailfishApp::application(argc,argv);
    QQuickView *view = SailfishApp::createView();

    RandomVocabulary random_vocabulary;
    SimpleInterface simple_interface;

    view->rootContext()->setContextProperty("random_vocabulary", &random_vocabulary);
    view->rootContext()->setContextProperty("simple_interface", &simple_interface);

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
    operations.append("CREATE TABLE vocabulary (word TEXT PRIMARY KEY, translation TEXT, priority INT)");
    operations.append("INSERT INTO meta VALUES ('version', '1')");

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
    QStringList operations;
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
        DEBUG("Database version: 1");
        return true;
        break;

        // For later usage
        for(QStringList::const_iterator s = operations.cbegin(); s != operations.cend(); ++s)
        {
            if(!query.exec(*s))
            {
                QString error = *s;
                error.append(": ").append(query.lastError().text());
                CRITICAL(error);
                return false;
            }
        }
        DEBUG("Upgrade complete");

    default:
        WARNING("Unknown database version");
        return false;
        break;
    }
}
