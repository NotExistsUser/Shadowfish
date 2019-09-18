Name:       jolla-settings-shadowfish

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

Summary:    V2ray control UI
Version:    0.3.2
Release:    1
Group:      Qt/Qt
License:    MIT
Source0:    %{name}-%{version}.tar.bz2
Requires:   v2ray >= 4.17.0
Requires:   bind-utils

%description
V2ray control UI, support Vmess and Shadowsocks protocol


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/home/nemo/.v2ray
# >> install pre
%qmake5_install


# << install pre

# >> install post
# << install post

%preun
# >> preun
dbus-send --system --type=method_call \
--dest=xyz.freedom.v2ray /xyz/freedom/v2ray \
xyz.freedom.v2ray.quit
# << preun

%post
# >> post
dbus-send --system --type=method_call \
--dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig
sed -i 's/\r//' /usr/bin/shadowfish.sh
systemctl daemon-reload
chown -R nemo:nemo /home/nemo/.config/v2ray
# << post

%postun
# >> postun
dbus-send --system --type=method_call \
--dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig
# << postun

%files
%defattr(-,root,root,-)
%attr(0755, root, root) %{_bindir}/*
%{_datadir}/jolla-settings/entries
%{_datadir}/jolla-settings/pages
%{_datadir}/dbus-1/
%{_datadir}/translations
%{_sysconfdir}/dbus-1/system.d/
%{_unitdir}/
%{_datadir}/themes/sailfish-default/meegotouch/
%config /home/nemo/.config/v2ray/config.json.template
# >> files
# << files
