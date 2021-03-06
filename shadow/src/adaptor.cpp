/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp dbus/xyz.freedom.v2ray.xml -i src/jolla-settings-v2ray.h -a src/adaptor
 *
 * qdbusxml2cpp is Copyright (C) 2016 The Qt Company Ltd.
 *
 * This is an auto-generated file.
 * Do not edit! All changes made to it will be lost.
 */

#include "src/adaptor.h"
#include <QtCore/QMetaObject>
#include <QtCore/QByteArray>
#include <QtCore/QList>
#include <QtCore/QMap>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>

/*
 * Implementation of adaptor class V2rayAdaptor
 */

V2rayAdaptor::V2rayAdaptor(QObject *parent)
    : QDBusAbstractAdaptor(parent)
{
    // constructor
    setAutoRelaySignals(true);
}

V2rayAdaptor::~V2rayAdaptor()
{
    // destructor
}

bool V2rayAdaptor::doProxy(const QString &fname)
{
    // handle method call xyz.freedom.v2ray.doProxy
    bool ok;
    QMetaObject::invokeMethod(parent(), "doProxy", Q_RETURN_ARG(bool, ok), Q_ARG(QString, fname));
    return ok;
}

