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

#include "simpleinterface.h"

SimpleInterface::SimpleInterface(QObject *parent) :
    QObject(parent),
    _count(0)
{
    recount();
}

int SimpleInterface::count()
{
    return _count;
}

void SimpleInterface::recount()
{
   _count = 0;
   QString s = "SELECT count(*) FROM vocabulary";
   QSqlQuery q(database);

   if(!q.exec(s))
   {
       QString error = s.append(": ").append(q.lastError().text());
       WARNING(error);
       return;
   }
   if(!q.isSelect())
   {
       QString error = s.append(": No select");
       WARNING(error);
       return;
   }
   if(!q.next())
   {
       QString error = s.append(": ").append(q.lastError().text());
       WARNING(error);
       return;
   }
   _count = q.value(0).toInt();
   emit countChanged(_count);
}

bool SimpleInterface::addVocabulary(QString word, QString translation)
{
    QString s = "INSERT INTO vocabulary (word, translation, priority) VALUES (?,?,100)";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word);
    q.addBindValue(translation);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return false;
    }
    _count += 1;
    emit countChanged(_count);
    return true;
}

bool SimpleInterface::removeVocabulary(QString word)
{
    QString s = "DELETE FROM vocabulary WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return false;
    }
    _count -= 1;
    emit countChanged(_count);
    return true;
}

QStringList SimpleInterface::getAllWords()
{
    QString s = "SELECT word FROM vocabulary ORDER BY word ASC";
    QSqlQuery q(database);

    q.prepare(s);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QStringList();
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return QStringList();
    }

    QStringList sl;
    while(q.next())
    {
        sl.append(q.value(0).toString());
    }
    return sl;

}

QString SimpleInterface::getTranslationOfWord(QString word)
{
    QString s = "SELECT translation FROM vocabulary WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return "";
    }
    if(!q.next())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    return q.value(0).toString();
}

