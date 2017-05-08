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

#include "databasetools.h"

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
#include <QDateTime>

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("harbour-vocabulary");
    QCoreApplication::setApplicationName("harbour-vocabulary");

    // Register QML types
    qmlRegisterType<Trainer>("harbour.vocabulary.Trainer", 1, 0, "Trainer");
    qmlRegisterType<SettingsProxy>("harbour.vocabulary.SettingsProxy", 1, 0, "SettingsProxy");
    qmlRegisterType<CSVHandle>("harbour.vocabulary.CSVHandle", 1, 0, "CSVHandle");
    // Needed for enum access
    qmlRegisterType<SimpleInterface>("harbour.vocabulary.SimpleInterface", 1, 0, "SimpleInterface");

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
        if(!DatabaseTools::create_new_db())
        {
            database.close();
            file.remove();
            FATAL("Can't create database.sqlite3");
        }
    }
    else
    {
        if(!DatabaseTools::test_and_update_db())
        {
            database.close();
            path.append("-UPGRADE_FAILED-");
            path.append(QDateTime::currentDateTime().toString(Qt::ISODate));
            if(file.rename(path))
            {
                FATAL(QString("Can't read/update database.sqlite3, moving to %1").arg(path));
            }
            else
            {
                if(file.remove())
                {
                    FATAL("Can't read/update database.sqlite3, removing it");
                }
                else
                {
                    FATAL("Can't read/update database.sqlite3, can not remove it! Please check your system");
                }
            }
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

