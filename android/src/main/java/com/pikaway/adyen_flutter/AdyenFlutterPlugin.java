package com.pikaway.adyen_flutter;

import android.app.Activity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.adyen.checkout.cse.CardEncrypter;
import com.adyen.checkout.cse.EncryptedCard;
import com.adyen.checkout.cse.UnencryptedCard;

import java.util.HashMap;
import java.util.Map;

/**
 * AdyenFlutterPlugin
 */
public class AdyenFlutterPlugin implements MethodCallHandler, FlutterPlugin {
    private MethodChannel methodChannel;

    // V2 Embedding Registration (Comes form FlutterPlugin interface)
    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        methodChannel = new MethodChannel(binding.getBinaryMessenger(), "adyen_flutter");
        methodChannel.setMethodCallHandler(this);
    }

    // V2 Embedding Unregistration (Comes form FlutterPlugin interface)
    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Plugin not passing a map as parameter: " + call.arguments);
        }
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        switch (call.method) {
            case "encryptedCard":
                try {
                    result.success(getEncryptedCard(arguments));
                } catch (Exception ex) {
                    result.error("Error", "Get encrypted Card failed.", ex);
                }
                break;
            default:
                result.notImplemented();
        }
    }

    private Map<Object, Object> getEncryptedCard(Map<String, Object> arguments) throws Error {
        String publicKeyToken = (String) arguments.get("publicKeyToken");
        String cardNumber = (String) arguments.get("cardNumber");
        String cardSecurityCode = (String) arguments.get("cardSecurityCode");
        int cardExpiryMonth = Integer.parseInt((String) arguments.get("cardExpiryMonth"));
        int cardExpiryYear = Integer.parseInt((String) arguments.get("cardExpiryYear"));
        UnencryptedCard unencryptedCard = new UnencryptedCard.Builder().setNumber(cardNumber).setExpiryMonth(String.valueOf(cardExpiryMonth))
                .setExpiryYear(String.valueOf(cardExpiryYear))
                .setCvc(cardSecurityCode)
                .build();

        EncryptedCard encryptedCard = CardEncrypter.encryptFields(unencryptedCard, publicKeyToken);
        try {
            Map<Object, Object> dict = new HashMap<>();
            dict.put("encryptedNumber", encryptedCard.getEncryptedCardNumber());
            dict.put("encryptedSecurityCode", encryptedCard.getEncryptedSecurityCode());
            dict.put("encryptedExpiryMonth", encryptedCard.getEncryptedExpiryMonth());
            dict.put("encryptedExpiryYear", encryptedCard.getEncryptedExpiryYear());
            return dict;
        } catch (Exception ex) {
            throw new Error("Could not encrypt the card", ex);
        }
    }
}
