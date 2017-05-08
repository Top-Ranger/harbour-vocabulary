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

#ifndef SIMPLEINTERFACE_H
#define SIMPLEINTERFACE_H

#include "global.h"

#include <QObject>
#include <QDate>

class SimpleInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum sortcriterium
    {
        NO_SORT = 0,
        ALPHABETICAL_WORD = 1, // Give word sorting as default from settings
        ALPHABETICAL_TRANSLATION,
        PRIORITY_HIGHEST,
        PRIORITY_LOWEST,
        CREATION_NEWEST,
        CREATION_OLDEST,
        MODIFICATION_NEWEST,
        MODIFICATION_OLDEST,
        NUMBER_ASKED_HIGHEST,
        NUMBER_ASKED_LOWEST,
        NUMBER_CORRECT_HIGHEST,
        NUMBER_CORRECT_LOWEST,
        PERCENT_CORRECT_HIGHEST,
        PERCENT_CORRECT_LOWEST
    };
    Q_ENUMS(sortcriterium)

    explicit SimpleInterface(QObject *parent = 0);
    int count();
    Q_INVOKABLE bool clearAllVocabulary();

signals:
    void countChanged(int);

public slots:
    // Vocabulary based methods
    bool addVocabulary(QString word, QString translation, int language);
    bool removeVocabulary(int id);
    bool editVocabulary(int id, QString new_word, QString translation, int priority, int language);
    bool setPriority(int id, int priority);
    QList<int> getAllWords(sortcriterium c);
    QString getWord(int id);
    QString getTranslationOfWord(int id);
    int getPriorityOfWord(int id);
    QDate getCreationDate(int id);
    QDate getModificationDate(int id);
    int getLanguageId(int id);
    int getNumberAsked(int id);
    int getNumberCorrect(int id);
    bool removeBatchVocabulary(QList<int> ids);
    QList<QString> getBatchWord(QList<int> ids);
    QList<QString> getBatchTranslationOfWord(QList<int> ids);
    QList<int> getBatchPriorityOfWord(QList<int> ids);
    bool resetTestCountsAll();
    bool resetTestCounts(int id);
    void recount();

    // Language based methods

    QVariantList getAllLanguages();
    int addLanguage(QString language);
    bool removeLanguage(int id);
    QString getLanguageName(int id);
    bool renameLanguage(int id, QString name);
    QVariantList getVocabularyByLanguage(int id, sortcriterium c);
    int countVocabularyWithLanguage(int id);
    bool moveToLanguage(int lid, QVariantList v_list);

private:
    void append_sorting_criterium(QString &q, const sortcriterium &c);

    int _count;
};

#endif // SIMPLEINTERFACE_H
