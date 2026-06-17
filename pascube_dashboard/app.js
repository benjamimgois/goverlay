// Pascube Benchmark Dashboard Logic

const SPREADSHEET_URL = "https://docs.google.com/spreadsheets/d/1nlMgeW0ZFmtwwT3hty8JAFT3sM0SNhMpc24mH3In9zI/export?format=csv";

// Fallback CSV Data to ensure the dashboard works even offline or in case of CORS/network issues
const FALLBACK_CSV = `Origem / Usuário,CPU,RAM,GPU,VRAM,Driver,Kernel,Operating System,Main Score,CPU Single,CPU Multi,GPU Score,Date/Time
Anonymous,Ryzen 7 9800X3D,31GB,RTX 4090,24GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (daniel@Cafetera)  dom 31 may 2026 19:42:58 CEST,7.0.10-2-cachyos-custom,CachyOS,5174,2780,3655,7306,16/06/2026 13:11:07
Anonymous,Ryzen 7 9800X3D,30GB,RTX 4090,24GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  595.80  Release Build  (dvs-builder@U22-I3-AF05-29-2)  Thu May 21 19:21:58 UTC 2026,7.0.12-201.fc44.x86_64,Fedora Linux 44 (KDE Plasma Desktop Edition),4975,2615,4019,6913,
Anonymous,Ryzen 9 7950X3D 16-Core,63GB,RX 7900 XTX,24GB,Mesa 26.1.99,7.0.12-1-cachyos,CachyOS,4938,3481,10783,4205,14/06/2026 14:22:49
Anonymous,Ryzen 9 9950X3D,96 GB,RX 9070 XT,,,,Arch Linux,4932,3576,11897,3791,
Anonymous,Ryzen 9 9900X3D 12-Core,60GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,4665,3731,9404,3897,14/06/2026 13:14:56
Anonymous,Ryzen 7 9800X3D,94GB,RTX 5070 Ti,,,,CachyOS,4609,3978,5679,4729,
Anonymous,Ryzen 7 9800X3D,96 GB,RTX 5070 Ti,,,,CachyOS,4546,N/D,N/D,N/D,
Anonymous,Ryzen 7 9800X3D,94GB,RTX 5070 Ti,,,,CachyOS,4546,"3,909","5,438","4,725",
Anonymous,RYZEN AI MAX+ 395 w/ Radeon 8060S,125GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,4513,3062,10564,3713,
Anonymous,Ryzen 7 7800X3D,62GB,RX 7900 XTX,,,,CachyOS,4465,"3,767","5,508","4,641",
Anonymous,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,4441,3980,5716,4382,
Anonymous,AMD Ryzen 9 9950X3D,96 GB,RX 9070 XT,,,,Arch Linux,4380,3754,12228,2464,
Anonymous,Ryzen 9 9950X3D,94GB,RX 9070 XT,,,,Arch Linux,4380,"3,754","12,228","2,464",
Anonymous,Ryzen 7 9800X3D,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,4323,4166,6530,3771,15/06/2026 04:48:03
Anonymous,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,4317,3929,5257,4307,14/06/2026 11:07:41
Anonymous,Ryzen 9 7950X3D 16-Core,62GB,RX 7900 XTX,24GB,Mesa 26.0.6,7.0.12-arch1-1,Arch Linux,4294,2603,7647,4471,15/06/2026 17:45:28
Anonymous,Ryzen 7 7800X3D,31GB,RX 7900 XTX,,,,CachyOS,4213,"3,689","5,503","4,193",
Anonymous,Ryzen 7 9800X3D,64 GB,RX 9070 XT,,,,Cachy OS,4207,N/D,N/D,N/D,
Anonymous,Ryzen 7 9800X3D,60GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,4133,4004,6475,3520,
Anonymous,Ryzen 7 9800X3D,32 GB,RX 9070 XT,,,,CachyOS,4131,N/D,N/D,N/D,
Anonymous,RYZEN AI MAX+ 395 w/ Radeon 8060S,125GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,4130,2545,9451,3644,
Anonymous,Ryzen 7 9800X3D,62GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.0.12-201.fc44.x86_64,Fedora Linux 44 (KDE Plasma Desktop Edition),4109,2915,5029,4668,15/06/2026 03:38:39
Anonymous,Ryzen 7 7800X3D,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.1.0-rc7-1-cachyos-rc,CachyOS,4100,3808,6109,3702,
Anonymous,Ryzen 7 7800X3D,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.1.0-rc7-1-cachyos-rc,CachyOS,4040,3813,5996,3613,
Anonymous,Ryzen 7 5800X 8-Core,31GB,RTX 5070 Ti,,,,CachyOS,4032,3053,4610,4544,
Anonymous,Ryzen 7 9800X3D,64 GB,RX 9070 XT,,,,Cachy OS,3989,N/D,N/D,N/D,
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,3889,3283,5120,3944,
Anonymous,Ryzen 9 9950X3D 16-Core,92GB,RX 9070 XT,15.9GB,Mesa 26.0.6,6.17.7-ba29.fc43.x86_64,Bazzite,3820,2290,7314,3842,16/06/2026 12:40:48
Anonymous,Ryzen 7 5800X 8-Core,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,3690,2995,4983,3789,15/06/2026 09:39:07
Anonymous,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.0.6,7.0.11-1-cachyos,CachyOS,3680,2703,3803,4327,
Anonymous,i5-14600KF,31GB,RTX 5070,12.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Wed Jun  3 22:21:41 UTC 2026,7.0.11-1-cachyos,CachyOS,3679,3058,6429,3289,
Anonymous,i5-14600KF,31GB,RTX 5070,12.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Wed Jun  3 22:21:41 UTC 2026,7.0.11-1-cachyos,CachyOS,3679,3058,6429,3289,
Anonymous,Ryzen 7 5800X 8-Core,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,3659,3008,4880,3748,14/06/2026 13:37:55
Anonymous,Ryzen 7 9800X3D,31GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.9-ogc3.2.fc44.x86_64,Bazzite,3656,3010,4980,3711,15/06/2026 08:21:30
Anonymous,Ryzen 7 9700X 8-Core,60GB,RX 7900 XTX,24GB,Mesa 26.0.6,7.0.12-zen1-1-zen,Arch Linux,3638,2304,3456,4627,16/06/2026 14:47:46
Anonymous,Ryzen 7 7800X3D,30GB,RX 9070 XT,15.9GB,Mesa 26.0.6,7.0.12-cachyos1.fc44.x86_64,Fedora Linux 44 (Forty Four),3498,2855,3869,3836,16/06/2026 06:15:59
Anonymous,Ryzen 7 9800X3D,31GB,RX 9070 XT,15.9GB,Mesa 26.0.6,7.0.12-201.fc44.x86_64,Fedora Linux 44 (KDE Plasma Desktop Edition),3412,2687,4274,3661,
Anonymous,Ryzen 7 7800X3D,47GB,RX 9070 XT,15.9GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,3393,3908,3496,3002,
Anonymous,Ryzen 9 5900X 12-Core,63 GB,RX 7800 XT,,,,Arch Linux,3367,2858,6.605,2751,
Anonymous,Ryzen 5 7500F 6-Core,31GB,RTX 5070,11.9GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (root@bezzerk-b650mgamingpluswifi),7.0.11-zen1-1-zen,Garuda Linux,3304,3336,4006,3070,
Anonymous,i7-4790K @ 4.00GHz,31GB,RTX 5070 Ti,,,,CachyOS,3225,2203,1458,4471,
Anonymous,AMD Ryzen 7 7800X3D,32 GiB,RX 6750 XT,,,,EndeavourOS,3194,N/D,N/D,N/D,
Anonymous,Ryzen 7 7800X3D,31GB,RX 6750 XT,,,,EndeavourOS,3194,"3,989","6,352","1,69",
Anonymous,Ryzen 7 7800X3D,31GB,RTX 4070,,,,Bazzite,3148,2804,4186,3078,
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 9070,15.9GB,Mesa 26.1.2,7.0.9-ogc3.2.fc44.x86_64,Bazzite,3078,2506,3548,3338,
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 9070,15.9GB,Mesa 26.1.2,7.0.9-ogc3.2.fc44.x86_64,Bazzite,3075,2510,3522,3337,
Anonymous,Ryzen 7 5800X3D 8-Core,16GB,RX 9070 XT,15.9GB,Mesa 26.0.6,7.0.12-arch1-1,Arch Linux,3069,2344,3125,3560,16/06/2026 07:11:39
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 9070,15.9GB,Mesa 26.1.2,7.0.9-ogc3.2.fc44.x86_64,Bazzite,3035,2439,3547,3299,
Anonymous,Ryzen 7 7800X3D,58GB,RTX 5070 Ti,15.9GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (root@Linusive),7.0.12-1-cachyos,Garuda Linux,3029,3936,6010,1500,
Anonymous,Ryzen 7 5800X3D 8-Core,32 GB,RX 9070 XT,,,,Fedora 44 KDE,3021,2308,3.385,3411,
Anonymous,Ryzen 7 9700X 8-Core,31GB,RX 9070,15.9GB,Mesa 26.0.6,7.0.9-ogc3.2.fc44.x86_64,Bazzite,2979,2444,3851,3092,16/06/2026 16:06:23
Anonymous,Ryzen 7 5800X3D 8-Core,63GB,RTX 5070,11.9GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Sat Jun 13 12:02:41 UTC 2026,7.0.12-1-cachyos,CachyOS,2970,2439,3559,3165,
Anonymous,i7-12700K,31GB,RX 7800 XT,,,,Arch Linux,2962,"2,699","4,096","2,806",
Anonymous,i7-4790K @ 4.00GHz,31GB,RTX 5070 Ti,16.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  580.126.09  Release Build  (dvs-builder@U22-I3-AM02-24-3)  Wed Jan  7 22:51:36 UTC 2026,6.19.10-2-liquorix-amd64,Ubuntu 24.04.4 LTS,2959,1627,1129,4440,
Anonymous,Ryzen 9 5900X 12-Core,31GB,RX 6900 XT,16GB,Mesa 26.1.2,7.0.9-200.nobara.fc43.x86_64,Nobara Linux 43 (KDE Plasma Desktop Edition),2954,2390,4546,2871,15/06/2026 10:36:04
Anonymous,Ryzen 5 5600X 6-Core,31GB,RX 9070 GRE,11.9GB,Mesa 26.1.1,6.18.33-1-MANJARO,Manjaro Linux,2946,2899,3228,2894,
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 6800 XT,,,,CachyOS,2935,3242,4396,2281,
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 6800,16GB,Mesa 26.1.2,7.0.10-1-cachyos-bore-lto,CachyOS,2930,3356,4598,2132,
Anonymous,Ryzen AI 9 HX 370 w/ Radeon 890M,94GB,RX 9070 XT,15.9GB,Mesa 26.0.6,7.0.0-22-generic,Ubuntu 26.04 LTS,2893,1704,2829,3745,16/06/2026 06:29:30
Anonymous,12th Gen i5-12400F,31GB,RX 9070,15.9GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,2820,2316,2936,3139,14/06/2026 16:00:38
Anonymous,Ryzen 7 5700X 8-Core,15GB,RX 9060 XT,16GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,2791,2987,4138,2249,
Anonymous,Ryzen 9 5900XT 16-Core,31GB,RX 6750 XT,12GB,Mesa 26.1.2,7.0.12-201.fc44.x86_64,Fedora Linux 44 (KDE Plasma Desktop Edition),2763,2501,6547,1812,
Anonymous,Ryzen 7 9700X 8-Core,30GB,RX 9060 XT,,,,CachyOS,2752,3759,4576,1500,
Anonymous,Ryzen 7 5800X3D 8-Core,31GB,RX 7800 XT,16GB,Mesa 26.0.6,7.0.12-1-cachyos,CachyOS,2710,2289,3187,2862,
Anonymous,Ryzen 7 5700X 8-Core,30GB,RX 6800,16GB,Mesa 26.0.6,7.0.0-22-generic,Ubuntu 26.04 LTS,2391,2176,3460,2220,16/06/2026 08:23:53
Anonymous,i7-9700K @ 3.60GHz,31GB,RX 9060 XT,,,,EndeavourOS,2387,2590,2852,2105,
Anonymous,Ryzen 9 3900X 12-C,31GB,RTX 3060 Ti,,,,CachyOS,2384,"2,113","4,886","1,823",
Anonymous,i7-9700K @ 3.60GHz,N/D,RX 9060 XT,,,,CachyOS,2330,N/D,N/D,N/D,
Anonymous,13th Gen i9-13900HX,31GB,RTX 4070 Laptop GPU,8GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  595.71.05  Release Build  (root@Mahoraga)  Tue Jun  2 17:06:29 CEST 2026,7.0.9-200.nobara.fc43.x86_64,Nobara Linux 43 (KDE Plasma Desktop Edition),2305,2152,4365,1794,
Anonymous,AMD Ryzen 7 5800x3d,32 GB,AMD Radeon RX 6700xt,,,,Nobara 43 KDE,2219,N/D,N/D,N/D,
Anonymous,i7-4790K @ 4.00GHz,31GB,RTX 5070 Ti,16.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  580.126.09  Release Build  (dvs-builder@U22-I3-AM02-24-3)  Wed Jan  7 22:51:36 UTC 2026,6.19.10-2-liquorix-amd64,Ubuntu 24.04.4 LTS,2203,1,1,4405,
Anonymous,i7-4790K @ 4.00GHz,31GB,RTX 5070 Ti,,,,Ubuntu 24.04.4 LTS,2202,1,1,4402,
Anonymous,i7-4790K @ 4.00GHz,31GB,RTX 5070 Ti,,,,Ubuntu 24.04.4 LTS,2200,1,1,4400,
Anonymous,AMD Ryzen 5 5600 6-Core,31 GB,Intel Arc A750 Graphics,,,,CachyOS,2169,2.992,3.245,1.270,
Anonymous,Ryzen 7 9800X3D,62GB,RX 7900 XTX,,,,PikaOS 4,1892,1,1,3784,
Anonymous,Ryzen 5 3600 6-Core,31GB,RTX 3060 Ti,8.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Sat Jun 13 12:02:41 UTC 2026,7.0.12-1-cachyos,CachyOS,1862,2156,2215,1550,16/06/2026 11:02:05
Anonymous,Ryzen 5 5600 6-Core,31GB,RX 6700,10GB,Mesa 26.1.2,7.0.9-200.nobara.fc43.x86_64,Nobara Linux 43 (KDE Plasma Desktop Edition),1851,2333,2723,1252,15/06/2026 03:23:04
Anonymous,Ryzen 5 7600X 6-Core,31GB,Intel(R) Arc(tm) B580 Graphics (BMG G21),11.9GB,Mesa 26.0.6,7.0.9-ogc3.2.fc44.x86_64,Bazzite,1844,2510,3060,1013,
Anonymous,12th Gen i5-12450HX,15GB,RTX 4050 Laptop GPU,6GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Wed Jun  3 22:21:41 UTC 2026,7.0.11-1-cachyos,CachyOS,1777,2152,2195,1390,
Anonymous,Ryzen 5 3600 6-Core,31GB,RX 6750 XT,12GB,Mesa 26.0.6,7.0.9-ogc3.2.fc44.x86_64,Bazzite,1693,1540,2034,1697,
Anonymous,Ryzen 5 5600G with Radeon Graphics,31GB,RX 6650 XT,8GB,Mesa 26.0.6,7.0.0-22-generic,Ubuntu 26.04 LTS,1660,1832,2245,1365,15/06/2026 20:41:15
Anonymous,i7-10870H @ 2.20GHz,31GB,RTX 3080 Laptop,,,,CachyOS,1520,"1,352",887,"1,617",
Anonymous,12th Gen i5-12400F,15GB,GTX 1060 6GB,6.2GB,NVRM version: NVIDIA UNIX x86_64 Kernel Module  580.159.04  Wed Apr 29 17:32:45 UTC 2026,7.0.12-zen1-1-zen,Garuda Linux,1513,2277,2545,669,
Anonymous,12th Gen i5-12400F,31GB,RX 6600,8GB,Mesa 26.0.6,7.0.9-200.nobara.fc43.x86_64,Nobara Linux 43 (KDE Plasma Desktop Edition),1438,1761,2221,978,16/06/2026 15:37:21
Anonymous,Ryzen 5 4600H with Radeon Graphics,15GB,GTX 1650 Ti,4.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Sat Jun 13 12:02:41 UTC 2026,7.0.12-1-cachyos,CachyOS,1320,1972,1947,676,16/06/2026 03:17:59
Anonymous,12th Gen i5-12450H,31GB,RTX 4060 Laptop GPU,8GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  595.80  Release Build  (dvs-builder@U22-I3-AF05-29-2)  Thu May 21 19:21:58 UTC 2026,7.0.12-201.fc44.x86_64,Fedora Linux 44 (KDE Plasma Desktop Edition),1312,1283,1178,1372,
Anonymous,i7-2600K @ 3.40GHz,16GB,RX 580,8GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,1298,2263,1558,544,
Anonymous,AMD Ryzen 7 3800XT,32 GB,GTX 1080,,,,Fedora 44 KDE (VM),1278,1294,1164,1300,
Anonymous,i7-2600K @ 3.40GHz,16GB,RX 580,8GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,1278,2228,1480,553,
Anonymous,Intel(R) Xeon(R) E5-2680 v3 @ 2.50GHz,16GB,GTX 980 Ti,6.2GB,NVRM version: NVIDIA UNIX x86_64 Kernel Module  580.159.04  Wed Apr 29 17:32:45 UTC 2026,7.0.12-201.fc44.x86_64,Fedora Linux 44 (Workstation Edition),1259,1119,2231,1065,
Anonymous,Ryzen Z1 Extreme,11 GB,Ryzen Z1 Extreme,,,,Bazzite (ROG Ally Z1E),1144,N/D,N/D,N/D,
Anonymous,Ryzen 5 5600G with Radeon Graphics,15GB,RX 580,8GB,Mesa 26.0.6,6.17.0-35-generic,Zorin OS 18.1,1143,1708,2017,485,15/06/2026 12:23:39
Anonymous,i7-9750H @ 2.60GHz,15GB,GTX 1660 Ti,6.2GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  610.43.02  Release Build  (notroot@)  Sat Jun 13 12:02:41 UTC 2026,7.0.12-1-cachyos,CachyOS,1112,1264,1098,1009,15/06/2026 09:19:31
Anonymous,11th Gen i5-11400H @ 2.70GHz,15GB,RTX 3050 Laptop GPU,4GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  580.159.03  Release Build  (dvs-builder@U22-I3-AM27-29-6)  Fri Apr 24 06:03:03 UTC 2026,7.0.11-76070011-generic,Pop!_OS 24.04 LTS,1060,1322,1327,796,16/06/2026 09:51:59
Anonymous,Ryzen 7 2700 Eight-Core,16GB,RX 590 Series,8GB,Mesa 26.0.6,6.17.0-35-generic,Linux Mint 22.3,978,1223,1556,634,16/06/2026 13:26:26
Anonymous,Intel(R) Xeon(R) E5-2667 v3 @ 3.20GHz,16GB,RX 580,8GB,Mesa 26.0.6,6.18.35-1-cachyos-lts,CachyOS,934,1183,1602,560,
Anonymous,Ryzen 5 5600H with Radeon Graphics,15GB,Graphics,5.3GB,Mesa 26.0.6,7.0.9-ogc3.2.fc44.x86_64,Bazzite,889,1569,1736,159,
Anonymous,i5-10500 @ 3.10GHz,15GB,Intel(R) UHD Graphics 630 (CML GT2),,,,CachyOS,847,1639,1491,100,
Anonymous,Custom APU 0405,14GB,AMD Custom GPU 0405,6GB,Mesa 26.1.2,6.11.11-valve29-1-neptune-611-g2dcfaf4df7ac,SteamOS,808,1454,1285,212,
Anonymous,i7-4770 @ 3.40GHz,16GB,RX 580,8GB,Mesa 26.0.6,7.0.11-arch1-1,Arch Linux,787,1266,901,417,
Anonymous,Ryzen 5 PRO 5650U with Radeon Graphics,23GB,Graphics,13.1GB,Mesa 26.0.6,7.0.9-200.nobara.fc43.x86_64,Nobara Linux 43 (KDE Plasma Desktop Edition),650,1181,1036,162,
Anonymous,i5-6400 @ 2.70GHz,12GB,R9 390 Series,8GB,Mesa 26.0.5,6.19.14-ogc5.1.fc44.x86_64,Bazzite,585,879,311,461,15/06/2026 14:41:25
Anonymous,i5-3470S @ 2.90GHz,16GB,GT 1030 (NVK GP108),2.3GB,NVIDIA 109051.91.0,6.17.0-35-generic,Zorin OS 18.1,528,1120,503,122,14/06/2026 12:29:55
Anonymous,11th Gen i5-11400H @ 2.70GHz,15GB,RTX 3050 Laptop GPU,4GB,NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  580.159.03  Release Build  (dvs-builder@U22-I3-AM27-29-6)  Fri Apr 24 06:03:03 UTC 2026,7.0.11-76070011-generic,Pop!_OS 24.04 LTS,407,1,1,813,16/06/2026 12:20:04
Anonymous,i5-5250U @ 1.60GHz,8GB,Intel(R) HD Graphics 6000 (BDW GT3),7.7GB,Mesa 26.1.2,6.14.0-37-generic,Linux Mint 22.3,54,1,1,107,14/06/2026 18:04:47`;

// State Variables
let benchmarkData = [];
let filteredData = [];
let chartInstances = {};
let currentSort = { column: 'mainScore', direction: 'desc' };

// Initialize Application
document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    fetchData();
});

// Setup Events (search, filter, sort, sync)
function setupEventListeners() {
    document.getElementById('refresh-btn').addEventListener('click', fetchData);
    document.getElementById('search-input').addEventListener('input', handleFilterChange);
    document.getElementById('os-filter').addEventListener('change', handleFilterChange);
    
    // Sort columns
    const headers = document.querySelectorAll('#leaderboard-table th.sortable');
    headers.forEach(header => {
        header.addEventListener('click', () => {
            const column = header.getAttribute('data-sort');
            handleSort(column);
        });
    });
}

// Fetch CSV Data
async function fetchData() {
    showLoading();
    setSyncStatus('syncing', 'Syncing...');
    
    // 1. Direct Fetch
    try {
        const response = await fetch(SPREADSHEET_URL);
        if (response.ok) {
            const csvText = await response.text();
            processCSVData(csvText);
            setSyncStatus('success', 'Synced (Direct)');
            return;
        }
    } catch (e) {
        console.warn("Direct fetch failed (CORS). Trying corsproxy.io...");
    }
    
    // 2. corsproxy.io
    try {
        const proxyUrl = `https://corsproxy.io/?${encodeURIComponent(SPREADSHEET_URL)}`;
        const response = await fetch(proxyUrl);
        if (response.ok) {
            const csvText = await response.text();
            processCSVData(csvText);
            setSyncStatus('success', 'Synced (Proxy)');
            return;
        }
    } catch (e) {
        console.warn("corsproxy.io failed. Trying AllOrigins...");
    }

    // 3. allorigins.win
    try {
        const proxyUrl = `https://api.allorigins.win/raw?url=${encodeURIComponent(SPREADSHEET_URL)}`;
        const response = await fetch(proxyUrl);
        if (response.ok) {
            const csvText = await response.text();
            processCSVData(csvText);
            setSyncStatus('success', 'Synced (AllOrigins)');
            return;
        }
    } catch (e) {
        console.error("All CORS proxies failed. Using offline fallback.", e);
    }
    
    // Fallback
    processCSVData(FALLBACK_CSV);
    setSyncStatus('warning', 'Using Fallback Data');
}

// Helper to update sync/refresh button visual state
function setSyncStatus(type, message) {
    const btn = document.getElementById('refresh-btn');
    const icon = btn.querySelector('i');
    const text = btn.querySelector('span');
    
    // Reset classes
    btn.className = 'btn';
    icon.className = '';
    
    if (type === 'syncing') {
        btn.classList.add('btn-secondary');
        icon.setAttribute('data-lucide', 'refresh-cw');
        icon.classList.add('spin');
        text.textContent = message;
    } else if (type === 'success') {
        btn.classList.add('btn-primary');
        icon.setAttribute('data-lucide', 'check');
        text.textContent = message;
        setTimeout(() => {
            text.textContent = 'Sync Data';
            icon.setAttribute('data-lucide', 'refresh-cw');
            lucide.createIcons();
        }, 3000);
    } else {
        btn.classList.add('btn-secondary');
        btn.style.border = '1px solid var(--warning)';
        icon.setAttribute('data-lucide', 'alert-circle');
        text.textContent = message;
    }
    
    lucide.createIcons();
}

// Show loader in table
function showLoading() {
    const tbody = document.getElementById('leaderboard-body');
    tbody.innerHTML = `
        <tr>
            <td colspan="11" class="loading-state">
                <div class="spinner"></div>
                <p>Loading benchmark data...</p>
            </td>
        </tr>
    `;
}

// Safe numeric cleaner
function cleanNumber(val) {
    if (!val) return null;
    const cleanStr = val.replace(/"/g, '').replace(/,/g, '').trim();
    if (cleanStr === 'N/D' || cleanStr === 'N/A' || cleanStr === '') return null;
    const num = Number(cleanStr);
    return isNaN(num) ? null : num;
}

// Process CSV content
function processCSVData(csvText) {
    const parsed = parseCSV(csvText);
    if (parsed.length <= 1) {
        showError('No records found in CSV file.');
        return;
    }
    
    // Map headers to column index
    // Expected headers: Origem / Usuário,CPU,RAM,GPU,VRAM,Driver,Kernel,Operating System,Main Score,CPU Single,CPU Multi,GPU Score,Date/Time
    const headers = parsed[0].map(h => h.toLowerCase().trim());
    
    const dataRows = parsed.slice(1);
    benchmarkData = dataRows.map(row => {
        if (row.length < 5) return null; // skip malformed lines
        
        return {
            user: row[0] || 'Anonymous',
            cpu: row[1] || 'Unknown CPU',
            ram: row[2] || 'N/D',
            gpu: row[3] || 'Unknown GPU',
            vram: row[4] || 'N/D',
            driver: row[5] || 'N/D',
            kernel: row[6] || 'N/D',
            os: row[7] || 'Linux',
            mainScore: cleanNumber(row[8]),
            cpuSingle: cleanNumber(row[9]),
            cpuMulti: cleanNumber(row[10]),
            gpuScore: cleanNumber(row[11]),
            dateTime: row[12] || 'N/D'
        };
    }).filter(row => row !== null && (row.mainScore !== null || row.cpuSingle !== null || row.cpuMulti !== null || row.gpuScore !== null));
    
    // Set up unique OS Filter options
    populateOsFilter();
    
    // Initial Filter & Sort (Sort by Main Score descending)
    filteredData = [...benchmarkData];
    sortData(currentSort.column, currentSort.direction);
    
    // Render Dashboard
    renderOverviewStats();
    renderCharts();
    renderTable();
}

// Parses standard CSV string correctly handling encapsulated quotes with commas
function parseCSV(text) {
    const lines = text.split(/\r?\n/);
    const result = [];
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        
        const cells = [];
        let inQuotes = false;
        let currentCell = '';
        
        for (let j = 0; j < line.length; j++) {
            const char = line[j];
            if (char === '"') {
                inQuotes = !inQuotes;
            } else if (char === ',' && !inQuotes) {
                cells.push(currentCell.trim());
                currentCell = '';
            } else {
                currentCell += char;
            }
        }
        cells.push(currentCell.trim());
        result.push(cells);
    }
    return result;
}

// Populate OS Dropdown Filter
function populateOsFilter() {
    const osFilter = document.getElementById('os-filter');
    // Save current selected value
    const selectedVal = osFilter.value;
    
    // Get unique OS values
    const osList = new Set();
    benchmarkData.forEach(row => {
        if (row.os && row.os.trim() !== '' && row.os !== 'N/D') {
            osList.add(row.os.trim());
        }
    });
    
    // Re-fill os filter
    osFilter.innerHTML = '<option value="">All Operating Systems</option>';
    Array.from(osList).sort().forEach(os => {
        const option = document.createElement('option');
        option.value = os;
        option.textContent = os;
        osFilter.appendChild(option);
    });
    
    // Restore selection if valid
    if (osList.has(selectedVal)) {
        osFilter.value = selectedVal;
    }
}

// Handle Filters
function handleFilterChange() {
    const searchQuery = document.getElementById('search-input').value.toLowerCase().trim();
    const osSelection = document.getElementById('os-filter').value;
    
    filteredData = benchmarkData.filter(row => {
        // Search filter
        const matchesSearch = !searchQuery || 
            row.cpu.toLowerCase().includes(searchQuery) ||
            row.gpu.toLowerCase().includes(searchQuery) ||
            row.os.toLowerCase().includes(searchQuery) ||
            row.user.toLowerCase().includes(searchQuery);
            
        // OS filter
        const matchesOs = !osSelection || row.os === osSelection;
        
        return matchesSearch && matchesOs;
    });
    
    // Keep current sort
    sortData(currentSort.column, currentSort.direction);
    
    // Re-render
    renderTable();
}

// Render Overview Statistics
function renderOverviewStats() {
    document.getElementById('stat-total-runs').textContent = benchmarkData.length;
    
    // Find absolute highest scores
    let topSingle = { score: 0, hardware: '-' };
    let topMulti = { score: 0, hardware: '-' };
    let topGpu = { score: 0, hardware: '-' };
    
    benchmarkData.forEach(row => {
        if (row.cpuSingle && row.cpuSingle > topSingle.score) {
            topSingle.score = row.cpuSingle;
            topSingle.hardware = row.cpu;
        }
        if (row.cpuMulti && row.cpuMulti > topMulti.score) {
            topMulti.score = row.cpuMulti;
            topMulti.hardware = row.cpu;
        }
        if (row.gpuScore && row.gpuScore > topGpu.score) {
            topGpu.score = row.gpuScore;
            topGpu.hardware = row.gpu;
        }
    });
    
    document.getElementById('stat-top-cpu-single').textContent = topSingle.score || '-';
    document.getElementById('stat-top-cpu-single-sub').textContent = topSingle.hardware;
    
    document.getElementById('stat-top-cpu-multi').textContent = topMulti.score ? topMulti.score.toLocaleString() : '-';
    document.getElementById('stat-top-cpu-multi-sub').textContent = topMulti.hardware;
    
    document.getElementById('stat-top-gpu').textContent = topGpu.score ? topGpu.score.toLocaleString() : '-';
    document.getElementById('stat-top-gpu-sub').textContent = topGpu.hardware;
}

// Sort data table columns
function handleSort(column) {
    let direction = 'asc';
    if (currentSort.column === column && currentSort.direction === 'asc') {
        direction = 'desc';
    }
    
    currentSort = { column, direction };
    
    // Update sorted headers CSS styles
    const headers = document.querySelectorAll('#leaderboard-table th');
    headers.forEach(header => {
        header.classList.remove('sorted-asc', 'sorted-desc');
        // Clear old icon inside header (if not rank, etc.)
        const icon = header.querySelector('i');
        if (icon) {
            icon.setAttribute('data-lucide', 'chevrons-up-down');
        }
    });
    
    const activeHeader = document.querySelector(`#leaderboard-table th[data-sort="${column}"]`);
    if (activeHeader) {
        activeHeader.classList.add(direction === 'asc' ? 'sorted-asc' : 'sorted-desc');
        const icon = activeHeader.querySelector('i');
        if (icon) {
            icon.setAttribute('data-lucide', direction === 'asc' ? 'chevron-up' : 'chevron-down');
        }
        lucide.createIcons();
    }
    
    sortData(column, direction);
    renderTable();
}

// Sort Logic Helper
function sortData(column, direction) {
    const isAsc = direction === 'asc';
    
    filteredData.sort((a, b) => {
        let valA, valB;
        
        switch (column) {
            case 'rank':
                // Rank is based on Main Score descending
                valA = a.mainScore || 0;
                valB = b.mainScore || 0;
                // Swap values to match direction (rank 1 = highest main score)
                return isAsc ? valB - valA : valA - valB;
            case 'cpu':
                valA = a.cpu.toLowerCase();
                valB = b.cpu.toLowerCase();
                break;
            case 'ram':
                valA = a.ram.toLowerCase();
                valB = b.ram.toLowerCase();
                break;
            case 'gpu':
                valA = a.gpu.toLowerCase();
                valB = b.gpu.toLowerCase();
                break;
            case 'vram':
                valA = a.vram.toLowerCase();
                valB = b.vram.toLowerCase();
                break;
            case 'os':
                valA = a.os.toLowerCase();
                valB = b.os.toLowerCase();
                break;
            case 'mainScore':
                valA = a.mainScore || 0;
                valB = b.mainScore || 0;
                break;
            case 'cpuSingle':
                valA = a.cpuSingle || 0;
                valB = b.cpuSingle || 0;
                break;
            case 'cpuMulti':
                valA = a.cpuMulti || 0;
                valB = b.cpuMulti || 0;
                break;
            case 'gpuScore':
                valA = a.gpuScore || 0;
                valB = b.gpuScore || 0;
                break;
            case 'date':
                valA = a.dateTime;
                valB = b.dateTime;
                break;
            default:
                valA = a.mainScore || 0;
                valB = b.mainScore || 0;
        }
        
        if (valA < valB) return isAsc ? -1 : 1;
        if (valA > valB) return isAsc ? 1 : -1;
        return 0;
    });
}

// Render Table Rows
function renderTable() {
    const tbody = document.getElementById('leaderboard-body');
    
    if (filteredData.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="11" style="text-align: center; padding: 3rem; color: var(--text-secondary);">
                    No benchmark results match your search or filters.
                </td>
            </tr>
        `;
        return;
    }
    
    // Sort reference table by main score to compute absolute ranks
    const sortedByScore = [...benchmarkData].sort((a, b) => (b.mainScore || 0) - (a.mainScore || 0));
    
    tbody.innerHTML = '';
    
    filteredData.forEach(row => {
        // Calculate absolute rank based on its index in sortedByScore
        const absoluteRank = sortedByScore.findIndex(r => r === row) + 1;
        
        const tr = document.createElement('tr');
        
        tr.innerHTML = `
            <td class="rank-cell">${absoluteRank}</td>
            <td title="${row.cpu}">${row.cpu}</td>
            <td>${row.ram}</td>
            <td title="${row.gpu}">${row.gpu}</td>
            <td>${row.vram}</td>
            <td title="${row.os}">${row.os}</td>
            <td class="score-cell main">${row.mainScore ? row.mainScore.toLocaleString() : '<span class="nd-cell">N/D</span>'}</td>
            <td class="score-cell secondary">${row.cpuSingle ? row.cpuSingle.toLocaleString() : '<span class="nd-cell">N/D</span>'}</td>
            <td class="score-cell secondary">${row.cpuMulti ? row.cpuMulti.toLocaleString() : '<span class="nd-cell">N/D</span>'}</td>
            <td class="score-cell secondary">${row.gpuScore ? row.gpuScore.toLocaleString() : '<span class="nd-cell">N/D</span>'}</td>
            <td style="font-size: 0.8rem; color: var(--text-secondary)">${row.dateTime}</td>
        `;
        
        tbody.appendChild(tr);
    });
}

// Render Interactive Charts using Chart.js
function renderCharts() {
    // 1. CPU Single Thread Top 8 Chart
    // Filter runs with valid CPU Single Scores
    const cpuSingleRuns = benchmarkData
        .filter(r => r.cpuSingle !== null)
        .sort((a, b) => b.cpuSingle - a.cpuSingle)
        .slice(0, 8);
    
    renderHorizontalBarChart(
        'cpuSingleChart',
        cpuSingleRuns.map(r => r.cpu),
        cpuSingleRuns.map(r => r.cpuSingle),
        'CPU Single Score',
        'rgba(99, 102, 241, 0.85)',
        '#818cf8'
    );
    
    // 2. CPU Multi Thread Top 8 Chart
    const cpuMultiRuns = benchmarkData
        .filter(r => r.cpuMulti !== null)
        .sort((a, b) => b.cpuMulti - a.cpuMulti)
        .slice(0, 8);
        
    renderHorizontalBarChart(
        'cpuMultiChart',
        cpuMultiRuns.map(r => r.cpu),
        cpuMultiRuns.map(r => r.cpuMulti),
        'CPU Multi Score',
        'rgba(168, 85, 247, 0.85)',
        '#c084fc'
    );
    
    // 3. GPU Performance Top 8 Chart
    const gpuRuns = benchmarkData
        .filter(r => r.gpuScore !== null)
        .sort((a, b) => b.gpuScore - a.gpuScore)
        .slice(0, 8);
        
    renderHorizontalBarChart(
        'gpuChart',
        gpuRuns.map(r => r.gpu),
        gpuRuns.map(r => r.gpuScore),
        'GPU Score',
        'rgba(14, 165, 233, 0.85)',
        '#38bdf8'
    );
}

// Horizontal Bar Chart Renderer
function renderHorizontalBarChart(canvasId, labels, data, datasetLabel, barColor, borderColor) {
    if (chartInstances[canvasId]) {
        chartInstances[canvasId].destroy();
    }
    
    const ctx = document.getElementById(canvasId).getContext('2d');
    
    // Chart configurations
    chartInstances[canvasId] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: datasetLabel,
                data: data,
                backgroundColor: barColor,
                borderColor: borderColor,
                borderWidth: 1.5,
                borderRadius: 6,
                borderSkipped: false,
                barPercentage: 0.65,
            }]
        },
        options: {
            indexAxis: 'y', // Makes it a horizontal bar chart
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false // Hide legend to keep it clean
                },
                tooltip: {
                    backgroundColor: 'rgba(15, 23, 42, 0.95)',
                    titleFont: {
                        family: "'Outfit', sans-serif",
                        size: 13,
                        weight: 'bold'
                    },
                    bodyFont: {
                        family: "'Inter', sans-serif",
                        size: 13
                    },
                    padding: 12,
                    borderColor: 'rgba(255, 255, 255, 0.15)',
                    borderWidth: 1,
                    cornerRadius: 8,
                    displayColors: false,
                    callbacks: {
                        label: function(context) {
                            return `${context.dataset.label}: ${context.parsed.x.toLocaleString()}`;
                        }
                    }
                }
            },
            scales: {
                x: {
                    grid: {
                        color: 'rgba(255, 255, 255, 0.05)',
                        tickBorderDash: [3, 3]
                    },
                    ticks: {
                        color: '#9ca3af',
                        font: {
                            family: "'Inter', sans-serif",
                            size: 11
                        }
                    }
                },
                y: {
                    grid: {
                        display: false // Hide Y axis grid lines
                    },
                    ticks: {
                        color: '#f3f4f6',
                        font: {
                            family: "'Outfit', sans-serif",
                            size: 11,
                            weight: 500
                        },
                        // Truncate long hardware names to prevent chart squeezing
                        callback: function(value) {
                            const label = this.getLabelForValue(value);
                            return label.length > 25 ? label.substring(0, 25) + '...' : label;
                        }
                    }
                }
            }
        }
    });
}

// Show Error state in table
function showError(message) {
    const tbody = document.getElementById('leaderboard-body');
    tbody.innerHTML = `
        <tr>
            <td colspan="11" style="text-align: center; padding: 3rem; color: var(--warning);">
                <i data-lucide="alert-triangle" style="width: 24px; height: 24px; margin: 0 auto 0.5rem; display: block;"></i>
                <p>${message}</p>
            </td>
        </tr>
    `;
    lucide.createIcons();
}
