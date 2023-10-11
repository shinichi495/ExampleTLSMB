package com.hdb.hds

import com.hdb.hds.env.HDBSDKEnvType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import okhttp3.tls.HandshakeCertificates
import okhttp3.tls.HeldCertificate
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.io.InputStream
import java.security.KeyPair
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate

class Example {
    private val okHttpClient = OkHttpClient.Builder().apply {
        val cf = CertificateFactory.getInstance("X.509")
        var pubCertInputStream: InputStream? = null
        if (env == HDBSDKEnvType.PROD) {
            pubCertInputStream = context?.resources?.openRawResource(R.raw.prod_cert)
        } else {
            pubCertInputStream = context?.resources?.openRawResource(R.raw.pub_cert)
        }
        val x509Certificate =
            cf.generateCertificate(pubCertInputStream) as X509Certificate

        val keyPair = KeyPair(x509Certificate.publicKey, loadPrivateKey())

        val handshakeCertificates: HandshakeCertificates = HandshakeCertificates.Builder()
            .addPlatformTrustedCertificates()
            .heldCertificate(HeldCertificate(keyPair, x509Certificate))
            .build()
        sslSocketFactory(
            handshakeCertificates.sslSocketFactory(),
            handshakeCertificates.trustManager
        )
        logInter.level = HttpLoggingInterceptor.Level.BODY
        addInterceptor(logInter)
    }
    private val retrofit = Retrofit.Builder()
        .baseUrl(envConfig?.baseUrl.orEmpty())
        .addConverterFactory(GsonConverterFactory.create())
        .client(okHttpClient.build())
        .build()
}