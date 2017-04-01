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

#ifndef LANGUAGEINTERFACE_H
#define LANGUAGEINTERFACE_H

#include "global.h"

#include<QObject>

class LanguageInterface : public QObject
{
    Q_OBJECT

public:
    LanguageInterface(QObject *parent = 0);

public slots:
    QVariantList getAllLanguages();
    int addLanguage(QString language);
    bool removeLanguage(int id);
    QString getLanguageName(int id);
    bool renameLanguage(int id, QString name);
    QVariantList getVocabularyByLanguage(int id);
    int countVocabularyWithLanguage(int id);

private:
};

#endif // LANGUAGEINTERFACE_H
