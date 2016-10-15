#ifndef SETTINGSPROXY_H
#define SETTINGSPROXY_H

#include "global.h"

#include <QObject>
#include <QSettings>

class SettingsProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int adaptiveTrainingCorrectPoints READ adaptiveTrainingCorrectPoints WRITE setAdaptiveTrainingCorrectPoints NOTIFY adaptiveTrainingCorrectPointsChanged)
    Q_PROPERTY(int adaptiveTrainingWrongPoints READ adaptiveTrainingWrongPoints WRITE setAdaptiveTrainingWrongPoints NOTIFY adaptiveTrainingWrongPointsChanged)
    Q_PROPERTY(bool adaptiveTrainingEnabled READ adaptiveTrainingEnabled WRITE setAdaptiveTrainingEnabled NOTIFY adaptiveTrainingEnabledChanged)

public:
    explicit SettingsProxy(QObject *parent = 0);

    int adaptiveTrainingCorrectPoints();
    int adaptiveTrainingWrongPoints();
    bool adaptiveTrainingEnabled();

signals:
    void adaptiveTrainingCorrectPointsChanged(int points);
    void adaptiveTrainingWrongPointsChanged(int points);
    void adaptiveTrainingEnabledChanged(bool enabled);

public slots:
    void setAdaptiveTrainingCorrectPoints(int points);
    void setAdaptiveTrainingWrongPoints(int points);
    void setAdaptiveTrainingEnabled(bool enabled);

private:
    QSettings _settings;
};

#endif // SETTINGSPROXY_H
