#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>

#include <QtCore/QCoreApplication>
#include "jolla-settings-v2ray.h"
#include "adaptor.h"
#include <iostream>

void help()
{
    std::cout << "Shadowfishd" << std::endl;
    std::cout << std::endl;
    std::cout << "Usage:" << std::endl;
    std::cout << "  shadowfishd                  : run as daemon" << std::endl;
    std::cout << "  shadowfishd -proxy <action> : do proxy actions, startSvc, stopSvc, startProxy or stopProxy" << std::endl;
}

int main(int argc, char **argv)
{
    if (getuid() != 0) {
        fprintf(stderr, "%s: Not running as root, exiting.\n", argv[0]);
        exit(2);
    }

    QCoreApplication app (argc, argv);
    V2rayObject V2rayObject;
    new V2rayAdaptor(&V2rayObject);
    QStringList arguments = app.arguments();

    // Daemon
    if (arguments.count() == 1) {
        V2rayObject.registerDBus();
        return app.exec();
    } else if (arguments.count() == 3) {
        if (arguments.at(1) == "-proxy") {
            QString fname = arguments.at(2);
            return V2rayObject.doProxy(fname) ? 0 : 2;
        }
    }

    help();
    return 1;
}
