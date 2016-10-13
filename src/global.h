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

#ifndef GLOBAL_H
#define GLOBAL_H

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QString>
#include <QStandardPaths>
#include <QFile>
#include <QDir>

#define DEBUG(x) qDebug() << "DEBUG in" << Q_FUNC_INFO << ":" << x
#define WARNING(x) qWarning() << "WARNING in" << Q_FUNC_INFO << ":" << x
#define CRITICAL(x) qCritical() << "CRITICAL in" << Q_FUNC_INFO << ":" << x
#define FATAL(x) qFatal("%s", QString("FATAL in %1: %2").arg(Q_FUNC_INFO).arg(x).toLatin1().data())

extern QSqlDatabase database;

#endif // GLOBAL_H

