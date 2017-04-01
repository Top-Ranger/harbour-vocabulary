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
 *
 */

#include "languageinterface.h"

#include<QDate>

LanguageInterface::LanguageInterface(QObject *parent) :
    QObject(parent)
{
}

QVariantList LanguageInterface::getAllLanguages()
{
    QString s = "SELECT rowid FROM language ORDER BY language ASC";
    QSqlQuery q(database);

    q.prepare(s);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return QVariantList();
    }
    if(!q.isSelect())
    {
        QString error = s;
        error.append(": No select");
        WARNING(error);
        return QVariantList();
    }

    QVariantList vl;
    while(q.next())
    {
        vl.append(q.value(0).toInt());
    }
    return vl;
}

int LanguageInterface::addLanguage(QString language)
{
    database.transaction();
    QString s = "INSERT INTO language (language) VALUES (:language)";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":language", language);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return -1;
    }
    database.commit();

    s = "SELECT last_insert_rowid()";

    if(!q.exec(s))
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return -1;
    }
    if(!q.isSelect())
    {
        QString error = s;
        error.append(": No select");
        WARNING(error);
        return -1;
    }
    if(!q.next())
    {
        QString error = s;
        error.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return -1;
    }
    return q.value(0).toInt();
}

bool LanguageInterface::removeLanguage(int id)
{
    if(countVocabularyWithLanguage(id) != 0)
    {
        WARNING("Can not remove a language with vocabulary in it");
        return false;
    }

    database.transaction();

    QString s = "DELETE FROM language WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    database.commit();
    return true;
}

QString LanguageInterface::getLanguageName(int id)
{
    QString s = "SELECT language FROM language WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    if(!q.isSelect())
    {
        QString error = s;
        error.append(": No select");
        WARNING(error);
        return "";
    }
    if(!q.next())
    {
        QString error = s;
        error.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    return q.value(0).toString();
}

bool LanguageInterface::renameLanguage(int id, QString name)
{
    name = name.simplified();

    // Update entry
    database.transaction();

    QSqlQuery q(database);
    QString s = "UPDATE language SET language=:l WHERE rowid=:id";
    q.prepare(s);
    q.bindValue(":l", name);
    q.bindValue(":id", id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    database.commit();
    return true;
}

QVariantList LanguageInterface::getVocabularyByLanguage(int id)
{
    QString s = "SELECT rowid FROM vocabulary WHERE language=:language ORDER BY word ASC";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":language", id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return QVariantList();
    }
    if(!q.isSelect())
    {
        QString error = s;
        error.append(": No select");
        WARNING(error);
        return QVariantList();
    }

    QVariantList vl;
    while(q.next())
    {
        vl.append(q.value(0).toInt());
    }
    return vl;
}

int LanguageInterface::countVocabularyWithLanguage(int id)
{
    QString s = "SELECT count(*) FROM vocabulary WHERE language=:language";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":language", id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return -1;
    }
    if(!q.isSelect())
    {
        QString error = s;
        error.append(": No select");
        WARNING(error);
        return -1;
    }
    if(!q.next())
    {
        QString error = s;
        error.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return -1;
    }
    return q.value(0).toInt();
}

bool LanguageInterface::moveToLanguage(int lid, QVariantList v_list)
{
    QString s = "UPDATE vocabulary SET language=:language, modification=:modification WHERE rowid=:id";
    qint64 date = QDate::currentDate().toJulianDay();
    QSqlQuery q(database);

    database.transaction();

    for(QVariantList::const_iterator i = v_list.constBegin(); i != v_list.constEnd(); ++i)
    {
        if(!(*i).canConvert<int>())
        {
            WARNING(QString("Can not convert %1 to int").arg((*i).typeName()));
            continue;
        }
        q.prepare(s);
        q.bindValue(":language", lid);
        q.bindValue(":modification", date);
        q.bindValue(":id", (*i).toInt());
        if(!q.exec())
        {
            QString error = s;
            error.append(": ").append(q.lastError().text());
            WARNING(error);
            database.rollback();
            return false;
        }
    }

    database.commit();
    return true;
}
