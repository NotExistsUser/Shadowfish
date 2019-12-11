#include "jolla-settings-v2ray.h"
#include "adaptor.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#include <QtCore/QCoreApplication>
#include <QtDBus/QDBusArgument>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusMetaType>
#include <QtDBus/QDBusVariant>
#include <QtCore/QProcess>
#include <QtCore/QTimer>
#include <QtCore/QDateTime>


static const char *SERVICE = "xyz.freedom.v2ray";
static const char *PATH = "/xyz/freedom/v2ray";
static const char *V2RAY_SCRIPT = "/usr/bin/shadowfish.sh";


V2rayObject::V2rayObject(QObject *parent) :
    QObject(parent), m_dbusRegistered(false)
{
    m_timer = new QTimer(this);
    m_adaptor = new V2rayAdaptor(this);
    connect(m_timer, &QTimer::timeout, this, &V2rayObject::quit);
    m_timer->setSingleShot(true);
    m_timer->setTimerType(Qt::VeryCoarseTimer);
    m_timer->setInterval(15000);  // Quit after 15s timeout
    m_timer->start();
}

V2rayObject::~V2rayObject()
{
    if (m_dbusRegistered) {
        QDBusConnection connection = QDBusConnection::systemBus();
        connection.unregisterObject(PATH);
        connection.unregisterService(SERVICE);
    }
}


void V2rayObject::registerDBus()
{
    if (!m_dbusRegistered) {
        // DBus
        QDBusConnection connection = QDBusConnection::systemBus();

        if (connection.interface()->isServiceRegistered(SERVICE)) {
            qWarning() << "### service already registered";
            return;
        }

        if (!connection.registerObject(PATH, this)) {
            QCoreApplication::quit();
            return;
        }else {
            qWarning() << "Object registered";
        }

        if (!connection.registerService(SERVICE)) {
            QCoreApplication::quit();
            return;
        }else {
            m_adaptor = new V2rayAdaptor(this);
            qWarning() << "Service registered";
            m_dbusRegistered = true;
        }


    }
}

bool V2rayObject::doProxy(const QString &fname)
{
    m_timer->stop();
    QProcess process;
    process.setProgram(V2RAY_SCRIPT);

    QStringList arguments;
    arguments.append(fname);

    process.setArguments(arguments);
    process.start();
    process.waitForFinished(-1);

    bool ok = (process.exitCode() == 0);
    m_timer->start();
    if(ok){
        qWarning() << fname;
        emit m_adaptor->statusChanged(fname);
    }
    return ok;
}


bool V2rayObject::event(QEvent *e)
{
    if (e->type() == QEvent::User) {
        e->accept();
        QCoreApplication::quit();
        return true;
    }
    return QObject::event(e);
}

void V2rayObject::quit()
{
    QCoreApplication::postEvent(this, new QEvent(QEvent::User));
}
