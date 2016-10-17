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

