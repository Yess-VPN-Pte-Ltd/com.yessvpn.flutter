package com.yessvpn.flutter.yess_vpn;

import android.content.Intent;
import android.net.VpnService;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
public class YessVPNService extends VpnService {

    @Override
    public IBinder onBind(Intent intent) {
        return super.onBind(intent);
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Configure a new interface from our VpnService instance. This must be done
        // from inside a VpnService.
        VpnService.Builder builder = new VpnService.Builder();

        // Create a local TUN interface using predetermined addresses. In your app,
        // you typically use values returned from the VPN gateway during handshaking.
        ParcelFileDescriptor localTunnel = builder
                .addAddress("192.168.2.2", 24)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("192.168.1.1")
                .establish();
        return super.onStartCommand(intent, flags, startId);
    }
}
