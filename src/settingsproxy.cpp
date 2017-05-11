#include "settingsproxy.h"

SettingsProxy::SettingsProxy(QObject *parent) :
    QObject(parent),
    _settings()
{
}

int SettingsProxy::adaptiveTrainingCorrectPoints()
{
    return _settings.value("adaptive_training/correct", 3).toInt();
}

int SettingsProxy::adaptiveTrainingWrongPoints()
{
    return _settings.value("adaptive_training/wrong", 10).toInt();
}

bool SettingsProxy::adaptiveTrainingEnabled()
{
    return _settings.value("adaptive_training/enabled", true).toBool();
}

int SettingsProxy::trainingFilterLanguage()
{
    return _settings.value("training_filter/language", -1).toInt();
}

bool SettingsProxy::trainingFilterCreationSinceEnabled()
{
    return _settings.value("training_filter/creation_since_enabled", false).toBool();
}

bool SettingsProxy::trainingFilterCreationUntilEnabled()
{
    return _settings.value("training_filter/creation_until_enabled", false).toBool();
}

bool SettingsProxy::trainingFilterModificationSinceEnabled()
{
    return _settings.value("training_filter/modification_since_enabled", false).toBool();
}

bool SettingsProxy::trainingFilterModificationUntilEnabled()
{
    return _settings.value("training_filter/modification_until_enabled", false).toBool();
}

QDate SettingsProxy::trainingFilterCreationSinceDate()
{
    return _settings.value("training_filter/creation_since_date", QDate::currentDate()).toDate();
}

QDate SettingsProxy::trainingFilterCreationUntilDate()
{
    return _settings.value("training_filter/creation_until_date", QDate::currentDate()).toDate();
}

QDate SettingsProxy::trainingFilterModificationSinceDate()
{
    return _settings.value("training_filter/modification_since_date", QDate::currentDate()).toDate();
}

QDate SettingsProxy::trainingFilterModificationUntilDate()
{
    return _settings.value("training_filter/modification_until_date", QDate::currentDate()).toDate();
}

int SettingsProxy::trainingFilterPriority()
{
    return _settings.value("training_filter/priority", 0).toInt();
}

int SettingsProxy::trainingFilterPercentageCorrect()
{
    return _settings.value("training_filter/percentage_correct", 100).toInt();
}

int SettingsProxy::addVocabularyLanguage()
{
    return _settings.value("add_vocabulary/language", -1).toInt();
}

bool SettingsProxy::trainingDirectStart()
{
    return _settings.value("training/direct_start", false).toBool();
}

int SettingsProxy::listSortCriterium()
{
    return _settings.value("list/sorting", 1).toInt();
}

bool SettingsProxy::listShowTranslation()
{
    return _settings.value("list/show_translation", true).toBool();
}

void SettingsProxy::setAdaptiveTrainingCorrectPoints(int points)
{
    _settings.setValue("adaptive_training/correct", points);
    emit adaptiveTrainingCorrectPointsChanged(points);
}

void SettingsProxy::setAdaptiveTrainingWrongPoints(int points)
{
    _settings.setValue("adaptive_training/wrong", points);
    emit adaptiveTrainingWrongPointsChanged(points);
}

void SettingsProxy::setAdaptiveTrainingEnabled(bool enabled)
{
    _settings.setValue("adaptive_training/enabled", enabled);
    emit adaptiveTrainingEnabledChanged(enabled);
}

void SettingsProxy::setTrainingFilterLanguage(int language)
{
    _settings.setValue("training_filter/language", language);
    emit adaptiveTrainingEnabledChanged(language);
}

void SettingsProxy::setTrainingFilterCreationSinceEnabled(bool enabled)
{
    _settings.setValue("training_filter/creation_since_enabled", enabled);
    emit trainingFilterCreationSinceEnabledChanged(enabled);
}

void SettingsProxy::setTrainingFilterCreationUntilEnabled(bool enabled)
{
    _settings.setValue("training_filter/creation_until_enabled", enabled);
    emit trainingFilterCreationUntilEnabledChanged(enabled);
}

void SettingsProxy::setTrainingFilterModificationSinceEnabled(bool enabled)
{
    _settings.setValue("training_filter/modification_since_enabled", enabled);
    emit trainingFilterModificationSinceEnabledChanged(enabled);
}

void SettingsProxy::setTrainingFilterModificationUntilEnabled(bool enabled)
{
    _settings.setValue("training_filter/modification_until_enabled", enabled);
    emit trainingFilterModificationUntilEnabledChanged(enabled);
}

void SettingsProxy::setTrainingFilterCreationSinceDate(QDate date)
{
    _settings.setValue("training_filter/creation_since_date", date);
    emit trainingFilterCreationSinceDateChanged(date);
}

void SettingsProxy::setTrainingFilterCreationUntilDate(QDate date)
{
    _settings.setValue("training_filter/creation_until_date", date);
    emit trainingFilterCreationUntilDateChanged(date);
}

void SettingsProxy::setTrainingFilterModificationSinceDate(QDate date)
{
    _settings.setValue("training_filter/modification_since_date", date);
    emit trainingFilterModificationSinceDateChanged(date);
}

void SettingsProxy::setTrainingFilterModificationUntilDate(QDate date)
{
    _settings.setValue("training_filter/modification_until_date", date);
    emit trainingFilterModificationUntilDateChanged(date);
}

void SettingsProxy::setTrainingFilterPriority(int priority)
{
    _settings.setValue("training_filter/priority", priority);
    emit trainingFilterPriorityChanged(priority);
}

void SettingsProxy::setTrainingFilterPercentageCorrect(int percentage)
{
    _settings.setValue("training_filter/percentage_correct", percentage);
    emit trainingFilterPercentageCorrectChanged(percentage);
}

void SettingsProxy::setAddVocabularyLanguage(int language)
{
    _settings.setValue("add_vocabulary/language", language);
    emit addVocabularyLanguageChanged(language);
}

void SettingsProxy::setTrainingDirectStart(bool direct)
{
    _settings.setValue("training/direct_start", direct);
    emit trainingDirectStartChanged(direct);
}

void SettingsProxy::setListSortCriterium(int c)
{
    _settings.setValue("list/sorting", c);
    emit listSortCriteriumChanged(c);
}

void SettingsProxy::setListShowTranslation(bool show)
{
    _settings.setValue("list/show_translation", show);
    emit listShowTranslationChanged(show);
}
