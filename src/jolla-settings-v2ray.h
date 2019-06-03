#ifndef GOSTBUTTON_H
#define GOSTBUTTON_H

#include <QtCore/QObject>
#include <QtCore/QSet>
#include <QtCore/QStringList>
#include <QtCore/QVariantMap>
#include <QtCore/QTimer>

class QTimer;
class V2rayAdaptor;
class V2rayObject : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "xyz.freedom.v2ray")
public:
    explicit V2rayObject(QObject *parent = 0);
    virtual ~V2rayObject();
    void registerDBus();
public slots:
    bool doProxy(const QString &fname);
    void quit();
protected:
    bool event(QEvent *e);
private:
    bool m_dbusRegistered;
    QTimer *m_timer;
    V2rayAdaptor *m_adaptor;
};

#endif // GOSTBUTTON_H
