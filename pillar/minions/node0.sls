kubernetes:
  node:
    subnet: 10.200.0.0/24

kubernetes-cni:
  version: 1.9.1

kubectl:
  version: 1.36.2

kubelet:
  version: 1.36.2

containerd:
  version: 2.3.3

kube-proxy:
  version: 1.36.2

# WARNING: The following section contains key files in clear text. In a real environment, this 
# should never be the case. Use gpg encryption via salt, or an external secrets manager to store 
# this kind of information.
# If you want to use this project in a real environment, please fork and replace this section 
# with a secure solution and your own keys/ca/certs. As I want this to work here out of the box,
# especially for learning purposes, this contains a working example with self-signed keys and 
# certificates.
pki:
  ca:
    cert: |
      -----BEGIN CERTIFICATE-----
      MIIFVjCCAz6gAwIBAgIUa49tv1xC9RPqrnktFRKjUmHkyDkwDQYJKoZIhvcNAQEN
      BQAwRjELMAkGA1UEBhMCREUxEzARBgNVBAgMCk11c3RlcmxhbmQxFTATBgNVBAcM
      DE11c3RlcmhhdXNlbjELMAkGA1UEAwwCQ0EwHhcNMjYwODA3MjIwOTE0WhcNMzYw
      ODA3MjIwOTE0WjBGMQswCQYDVQQGEwJERTETMBEGA1UECAwKTXVzdGVybGFuZDEV
      MBMGA1UEBwwMTXVzdGVyaGF1c2VuMQswCQYDVQQDDAJDQTCCAiIwDQYJKoZIhvcN
      AQEBBQADggIPADCCAgoCggIBAOAycLqQI73yq8njdi20NxkJqHyvciA4yNQuSsJB
      vB1PHTC5NP4dHlNTvq5j4DjVFLPOaHBRRX9/OwJtjOXJaGNqJLPdY0KqowohS8Qw
      5yl2oiSss7XMvP6qviYCIBKSaPgmjx6p5/C4gHCPsObvJ56oflr21Bb7GYta6V02
      JEx6D9vNW26MJKWUTSVH+HT/b2lTdBpri/7eLzDID4QaG6EI3SXRPlNM4Ej0RpgM
      NWKL+sE0ODAYsfwYXZr295g7koUuCQKWsvsn5i14OByWZStf2LeI4ifvx8aV3TFR
      HASpwyW3MvgrRqs9jMoBed6kD/SlO4sv046ysiM/asinxLc6MIyLy0zMyhAY8b3W
      8CH1A5E4fmUCRaqOTbTn3yiJrwMxmrem3MkMshUl3WGzxyVPoKsg6JbbODgCQXo5
      DOggN8cc/EzuIct6Hl8BpsPeRSbccae/+Ch6P6osjpV7u5be02VVptMfWvcsEk1N
      4HztOM9c3julpcbWszPUdlXCl1giv8b3wbUGYjUOLCettscqRkn9B6de8rbsbio9
      agShilPquP0xWMWIv4qAFYNQxehVLnzx+TacbhpEPie7TMIfpSmcVR3vgDmV+6ly
      T29Yw6t/7s45XFXmkcRABN0klIRWGBsvDJcPpGljgKDmfDYCWBMbR36vEXYImgOe
      sL9TAgMBAAGjPDA6MAwGA1UdEwQFMAMBAf8wCwYDVR0PBAQDAgEGMB0GA1UdDgQW
      BBStqJIQXbL5hYrpsXpnUNXOTePe6jANBgkqhkiG9w0BAQ0FAAOCAgEAxjnlnEFb
      +1AYz0GcXPozk02O9/UYQok0F8rvXPCHK2mBMlfs6hLt3LoWP5wj+yTSB09NKu74
      PmCM+/v7EhcfnWB9lWbszLeO22tIq4g+RLRTis/4Yqn4raodJhlzP2s0LVsG3Uij
      xfxAS2xbDa9VPOKPLNqkw1QdULGMOPF9qlTKqcNrbCRNYqCiPbfmKEa+IQLyCYwC
      JVDuXTqB+br8zO9xmXmTuqixaZXHrHOiXuQILHZAF+qar5Yjwuv6wjY+EuOKD0QQ
      Pg7VT8bMlJanlJaaRMFMAMcV24pCmWq3wYCKH3XqHKEAQOgGT3HjDkflFbC1i+p5
      KHiigLr06Lu5uSDbmcs7ss2bDDNxqkIHTQviYjr1Q1gy6FrKpefvqBnXZB6M6s6Y
      rc415czebIFbpmOuLpxHeK2Ld2N6luH8GHMTfdOggywm5E+tat/lvctcCB5WCEf+
      AuyhSL64RDTP7UjzUF/R8nt46jLR1mioozQMJPW2jTkovD+RkaxZrP7bJL6/Wg6B
      vgIrBiajduPZ7hKioJGuq1v5+gvZcmCreG13OEGlKrjVD7pzTKguNu+fR5/zmzDK
      ULRrJFgzh30iz5u7yvNXoSSQ3NhUNFr0fRjHK7wStWwgbzVAScMvcgGO60VdwatQ
      +ifuglmmJdel2u+T+u4XFhhzgqNIbVSK/3s=
      -----END CERTIFICATE-----
  kubelet:
    cert: |
      -----BEGIN CERTIFICATE-----
      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
      IBcQY8UeNIIi/ruBhp/n7Yjq
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      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
      vpuVMpajMQMaAlf1s7++B75xmvqs92g=
      -----END PRIVATE KEY-----
  kube-proxy:
    cert: |
      -----BEGIN CERTIFICATE-----
      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
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      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
      OS6ipO6dWQfKUDeHm329oc2hSpA1
      -----END PRIVATE KEY-----
