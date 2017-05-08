#ifndef SETTINGSPROXY_H
#define SETTINGSPROXY_H

#include "global.h"

#include <QObject>
#include <QSettings>
#include <QDate>

class SettingsProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int adaptiveTrainingCorrectPoints READ adaptiveTrainingCorrectPoints WRITE setAdaptiveTrainingCorrectPoints NOTIFY adaptiveTrainingCorrectPointsChanged)
    Q_PROPERTY(int adaptiveTrainingWrongPoints READ adaptiveTrainingWrongPoints WRITE setAdaptiveTrainingWrongPoints NOTIFY adaptiveTrainingWrongPointsChanged)
    Q_PROPERTY(bool adaptiveTrainingEnabled READ adaptiveTrainingEnabled WRITE setAdaptiveTrainingEnabled NOTIFY adaptiveTrainingEnabledChanged)

    Q_PROPERTY(int trainingFilterLanguage READ trainingFilterLanguage WRITE setTrainingFilterLanguage NOTIFY trainingFilterLanguageChanged)

    Q_PROPERTY(bool trainingFilterCreationSinceEnabled READ trainingFilterCreationSinceEnabled WRITE setTrainingFilterCreationSinceEnabled NOTIFY trainingFilterCreationSinceEnabledChanged)
    Q_PROPERTY(bool trainingFilterCreationUntilEnabled READ trainingFilterCreationUntilEnabled WRITE setTrainingFilterCreationUntilEnabled NOTIFY trainingFilterCreationUntilEnabledChanged)
    Q_PROPERTY(bool trainingFilterModificationSinceEnabled READ trainingFilterModificationSinceEnabled WRITE setTrainingFilterModificationSinceEnabled NOTIFY trainingFilterModificationSinceEnabledChanged)
    Q_PROPERTY(bool trainingFilterModificationUntilEnabled READ trainingFilterModificationUntilEnabled WRITE setTrainingFilterModificationUntilEnabled NOTIFY trainingFilterModificationUntilEnabledChanged)

    Q_PROPERTY(QDate trainingFilterCreationSinceDate READ trainingFilterCreationSinceDate WRITE setTrainingFilterCreationSinceDate NOTIFY trainingFilterCreationSinceDateChanged)
    Q_PROPERTY(QDate trainingFilterCreationUntilDate READ trainingFilterCreationUntilDate WRITE setTrainingFilterCreationUntilDate NOTIFY trainingFilterCreationUntilDateChanged)
    Q_PROPERTY(QDate trainingFilterModificationSinceDate READ trainingFilterModificationSinceDate WRITE setTrainingFilterModificationSinceDate NOTIFY trainingFilterModificationSinceDateChanged)
    Q_PROPERTY(QDate trainingFilterModificationUntilDate READ trainingFilterModificationUntilDate WRITE setTrainingFilterModificationUntilDate NOTIFY trainingFilterModificationUntilDateChanged)

    Q_PROPERTY(int trainingFilterPriority READ trainingFilterPriority WRITE setTrainingFilterPriority NOTIFY trainingFilterPriorityChanged)
    Q_PROPERTY(int trainingFilterPercentageCorrect READ trainingFilterPercentageCorrect WRITE setTrainingFilterPercentageCorrect NOTIFY trainingFilterPercentageCorrectChanged)

    Q_PROPERTY(int addVocabularyLanguage READ addVocabularyLanguage WRITE setAddVocabularyLanguage NOTIFY addVocabularyLanguageChanged)

    Q_PROPERTY(bool trainingDirectStart READ trainingDirectStart WRITE setTrainingDirectStart NOTIFY trainingDirectStartChanged)

    Q_PROPERTY(int listSortCriterium READ listSortCriterium WRITE setListSortCriterium NOTIFY listSortCriteriumChanged)

public:
    explicit SettingsProxy(QObject *parent = 0);

    int adaptiveTrainingCorrectPoints();
    int adaptiveTrainingWrongPoints();
    bool adaptiveTrainingEnabled();

    int trainingFilterLanguage();

    bool trainingFilterCreationSinceEnabled();
    bool trainingFilterCreationUntilEnabled();
    bool trainingFilterModificationSinceEnabled();
    bool trainingFilterModificationUntilEnabled();

    QDate trainingFilterCreationSinceDate();
    QDate trainingFilterCreationUntilDate();
    QDate trainingFilterModificationSinceDate();
    QDate trainingFilterModificationUntilDate();

    int trainingFilterPriority();
    int trainingFilterPercentageCorrect();

    int addVocabularyLanguage();

    bool trainingDirectStart();

    int listSortCriterium();

signals:
    void adaptiveTrainingCorrectPointsChanged(int points);
    void adaptiveTrainingWrongPointsChanged(int points);
    void adaptiveTrainingEnabledChanged(bool enabled);

    void trainingFilterLanguageChanged(int language);

    void trainingFilterCreationSinceEnabledChanged(bool enabled);
    void trainingFilterCreationUntilEnabledChanged(bool enabled);
    void trainingFilterModificationSinceEnabledChanged(bool enabled);
    void trainingFilterModificationUntilEnabledChanged(bool enabled);

    void trainingFilterCreationSinceDateChanged(QDate date);
    void trainingFilterCreationUntilDateChanged(QDate date);
    void trainingFilterModificationSinceDateChanged(QDate date);
    void trainingFilterModificationUntilDateChanged(QDate date);

    void trainingFilterPriorityChanged(int priority);
    void trainingFilterPercentageCorrectChanged(int percentage);

    void addVocabularyLanguageChanged(int language);

    void trainingDirectStartChanged(bool direct);

    void listSortCriteriumChanged(int c);

public slots:
    void setAdaptiveTrainingCorrectPoints(int points);
    void setAdaptiveTrainingWrongPoints(int points);
    void setAdaptiveTrainingEnabled(bool enabled);

    void setTrainingFilterLanguage(int language);

    void setTrainingFilterCreationSinceEnabled(bool enabled);
    void setTrainingFilterCreationUntilEnabled(bool enabled);
    void setTrainingFilterModificationSinceEnabled(bool enabled);
    void setTrainingFilterModificationUntilEnabled(bool enabled);

    void setTrainingFilterCreationSinceDate(QDate date);
    void setTrainingFilterCreationUntilDate(QDate date);
    void setTrainingFilterModificationSinceDate(QDate date);
    void setTrainingFilterModificationUntilDate(QDate date);

    void setTrainingFilterPriority(int priority);
    void setTrainingFilterPercentageCorrect(int percentage);

    void setAddVocabularyLanguage(int language);

    void setTrainingDirectStart(bool direct);

    void setListSortCriterium(int c);

private:
    QSettings _settings;
};

#endif // SETTINGSPROXY_H
