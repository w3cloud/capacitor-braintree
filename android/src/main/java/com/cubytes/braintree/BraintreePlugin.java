package com.cubytes.braintree;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

@NativePlugin()
public class BraintreePlugin extends Plugin {

    @PluginMethod()
    public void setToken(PluginCall call) {
        String token = call.getString("token");

        if (!call.getData().has("token")){
            call.reject("A token is required.");
            return;
        }
        call.resolve();
    }

    @PluginMethod()
    public void showDropIn(PluginCall call) {
        call.resolve();
    }
}
