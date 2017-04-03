/*
 * Copyright 2016.2017 Marcus Soll
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

#ifndef TRAINER_H
#define TRAINER_H

#include "global.h"

#include "settingsproxy.h"

#include <random>
#include <QObject>
#include <QVector>

class Trainer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString word READ word NOTIFY wordChanged)
    Q_PROPERTY(QString translation READ translation NOTIFY translationChanged)
    Q_PROPERTY(trainings_modus modus READ modus NOTIFY modusChanged)
    Q_PROPERTY(int language READ language NOTIFY languageChanged)

public:
    enum trainings_modus
    {
        GUESS_WORD,
        GUESS_TRANSLATION
    };
    
    enum filters
    {
        LANGUAGE = 1,
        MODIFICATION_SINCE = 2,
        MODIFICATION_UNTIL = 3,
        CREATION_SINCE = 4,
        CREATION_UNTIL = 5,
        MINIMUM_PRIORITY = 6,
        filters_after_enum = 7
    };
    Q_ENUMS(trainings_modus)
    Q_ENUMS(filters)

    explicit Trainer(QObject *parent = 0);
    QString word();
    QString translation();
    trainings_modus modus();
    int language();

signals:
    void wordChanged(QString word);
    void translationChanged(QString translation);
    void modusChanged(trainings_modus modus);
    void languageChanged(int language);

public slots:
    bool load_vocabulary(QVariantList filter_type, QVariantList filter_argv);
    int count_vocabulary(QVariantList filter_type, QVariantList filter_argv);
    void next();
    void correct();
    void wrong();

private:
    struct vocabulary
    {
        int id;
        QString word;
        QString translation;
        int priority;
        int language;
    };
    trainings_modus _modus;
    int _index;
    QVector<vocabulary> _vocabulary;
    int _sum;
    std::random_device _rnd;
    SettingsProxy _settings;

};

#endif // TRAINER_H
