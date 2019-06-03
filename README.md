# Shadowfish

For freedom !

## Thanks

Very thanks to gexc,AfterTheRainOfStars,patchmanager,coderus,etc...

### TODO

- [ ] Network connection test support 
- [ ] Template support
- [x] Multi config support



### Debug

```bash
dbus-send --print-reply --system --type=method_call \
 --dest=xyz.freedom.v2ray /xyz/freedom/v2ray \
 xyz.freedom.v2ray.doProxy string:'startProxy'
```

```
dbus-send --system --type=method_call --print-reply --dest=org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.DBus.Introspectable.Introspect|grep v2ray
```
