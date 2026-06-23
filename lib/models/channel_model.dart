import 'package:cloud_firestore/cloud_firestore.dart';

class Channel {
  final String id;
  final String name;
  final String category;
  final String streamUrl;
  final String logoUrl;
  final bool isActive;
  final int order;

  Channel({
    required this.id,
    required this.name,
    required this.category,
    required this.streamUrl,
    this.logoUrl = '',
    this.isActive = true,
    this.order = 0,
  });

  factory Channel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Channel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? 'Sports',
      streamUrl: d['streamUrl'] ?? '',
      logoUrl: d['logoUrl'] ?? '',
      isActive: d['isActive'] ?? true,
      order: d['order'] ?? 0,
    );
  }

  factory Channel.fromMap(Map<String, dynamic> d) {
    return Channel(
      id: d['id'] ?? '',
      name: d['name'] ?? '',
      category: d['category'] ?? 'Sports',
      streamUrl: d['streamUrl'] ?? '',
      logoUrl: d['logoUrl'] ?? '',
      isActive: d['isActive'] ?? true,
      order: d['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'streamUrl': streamUrl,
        'logoUrl': logoUrl,
        'isActive': isActive,
        'order': order,
      };

  Channel copyWith({
    String? id,
    String? name,
    String? category,
    String? streamUrl,
    String? logoUrl,
    bool? isActive,
    int? order,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}

class ChannelData {
  static final List<Channel> defaultChannels = [
    // ===== FIFA WORLD CUP 2026 =====
    Channel(id: 'fifa_andro',    name: 'FIFA Live (andro)',             category: 'FIFA 2026', streamUrl: 'https://andro.226503.xyz/checklist/androstreamlivebs1.m3u8',                                    logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'fifa_rtbgo',    name: 'FIFA rtbgo Master (Multi-Q)',   category: 'FIFA 2026', streamUrl: 'https://d1211whpimeups.cloudfront.net/smil:rtbgo/playlist.m3u8',                                logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'fifa_1080p',    name: 'FIFA rtbgo 1080p',              category: 'FIFA 2026', streamUrl: 'https://d1211whpimeups.cloudfront.net/smil:rtbgo/chunklist_b4096000_slENG.m3u8',               logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'fifa_720p',     name: 'FIFA rtbgo 720p',               category: 'FIFA 2026', streamUrl: 'https://d1211whpimeups.cloudfront.net/smil:rtbgo/chunklist_b2196000_sleng.m3u8',              logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'fifa_480p',     name: 'FIFA rtbgo 480p',               category: 'FIFA 2026', streamUrl: 'https://d1211whpimeups.cloudfront.net/smil:rtbgo/chunklist_b1120000_sleng.m3u8',              logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'fifa_360p',     name: 'FIFA rtbgo 360p',               category: 'FIFA 2026', streamUrl: 'https://d1211whpimeups.cloudfront.net/smil:rtbgo/chunklist_b608000_sleng.m3u8',               logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'bein_xtra',     name: 'beIN XTRA (Amagi Official)',    category: 'FIFA 2026', streamUrl: 'https://bein-xtra-bein.amagi.tv/playlist.m3u8',                                                logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'bein_xtra_es',  name: 'beIN XTRA Espanol (CloudFront)',category: 'FIFA 2026', streamUrl: 'https://dc1644a9jazgj.cloudfront.net/beIN_Sports_Xtra_Espanol.m3u8',                           logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'telemundo',     name: 'Telemundo USA (NBC Spanish)',   category: 'FIFA 2026', streamUrl: 'https://nbculocallive.akamaized.net/hls/live/2037499/puertorico/stream1/master.m3u8',           logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'w9_france',     name: 'W9 France (FIFA WC)',           category: 'FIFA 2026', streamUrl: 'https://origin-m6web.live.6cloud.fr/out/v1/6play/6play-w9/cmaf_q2hyb21h/hls-short-hd.m3u8',  logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'fox_usa',       name: 'FOX USA (FIFA WC English)',     category: 'FIFA 2026', streamUrl: 'http://84.17.50.102/fox/index.m3u8',                                                           logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'bein_hd23',     name: 'beIN Sports HD (CDN)',          category: 'FIFA 2026', streamUrl: 'https://1nyaler.streamhostingcdn.top/stream/23/index.m3u8',                                    logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'sport_89',      name: 'Sports Live HD [1]',            category: 'FIFA 2026', streamUrl: 'https://1nyaler.streamhostingcdn.top/stream/89/index.m3u8',                                    logoUrl: 'https://img.icons8.com/color/96/football2.png'),
    Channel(id: 'sport_106',     name: 'Sports Live HD [2]',            category: 'FIFA 2026', streamUrl: 'https://1nyaler.streamhostingcdn.top/stream/106/index.m3u8',                                   logoUrl: 'https://img.icons8.com/color/96/football2.png'),

    // ===== CRICKET =====
    Channel(id: 'tsports1',     name: 'T Sports HD',               category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/130714.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'tsports2',     name: 'T Sports HD [2]',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/18452.m3u8',    logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss1_eng_hd',   name: 'Star Sports 1 ENG HD',      category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/148.m3u8',      logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss1_eng_fhd',  name: 'Star Sports 1 ENG FHD',     category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/9397.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss1_eng_4k',   name: 'Star Sports 1 ENG 4K',      category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/124281.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss2_eng_hd',   name: 'Star Sports 2 ENG HD',      category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/239.m3u8',      logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss2_eng_fhd',  name: 'Star Sports 2 ENG FHD',     category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/9398.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss1_hin_hd',   name: 'Star Sports 1 HINDI HD',    category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/211.m3u8',      logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss1_hin_fhd',  name: 'Star Sports 1 HINDI FHD',   category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/9399.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss1_4k',       name: 'Star Sports 1 4K',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/98864.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ss2_4k',       name: 'Star Sports 2 4K',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/98865.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'sony1_hd',     name: 'Sony Sports 1 HD',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/154.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'sony2_hd',     name: 'Sony Sports 2 HD',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/31314.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'sony3_hd',     name: 'Sony Sports 3 HD',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/146.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'sony5_hd',     name: 'Sony Sports 5 HD',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/176.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ten2_hd',      name: 'Sony TEN 2 HD',              category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/192.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ten5_4k',      name: 'Sony TEN 5 4K',              category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/98870.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ten_hd',       name: 'Ten Sports HD',               category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/98.m3u8',     logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'willow1',      name: 'Willow Sports HD',            category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/215.m3u8',    logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'willow2',      name: 'Willow Sports HD [2]',        category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/23943.m3u8',  logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'willow3',      name: 'Willow 2 HD',                 category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/5040.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'willow_cf',    name: 'Willow HD Master (CDN)',       category: 'Cricket', streamUrl: 'https://d36r8jifhgsk5j.cloudfront.net/Willow_TV.m3u8',        logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'willow_1080p', name: 'Willow HD 1080p (CDN)',        category: 'Cricket', streamUrl: 'https://d36r8jifhgsk5j.cloudfront.net/Willow_TV1080p.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'willow_720p',  name: 'Willow HD 720p (CDN)',         category: 'Cricket', streamUrl: 'https://d36r8jifhgsk5j.cloudfront.net/Willow_TV720p.m3u8',    logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'sky_cric_hd',  name: 'Sky Sports Cricket HD',        category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/12.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'sky_cric_4k',  name: 'Sky Sports Cricket 4K',        category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/23566.m3u8', logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'fox_cric',     name: 'Fox Cricket 501 HD',           category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/1856.m3u8',  logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'ptv_sports',   name: 'PTV Sports HD',                category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/89.m3u8',    logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'a_sports',     name: 'A Sports HD',                  category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/43444.m3u8', logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'geo_super',    name: 'GEO Super HD',                 category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/101.m3u8',   logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'gtv_pk',       name: 'GTV Network PK',               category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/4058.m3u8',  logoUrl: 'https://img.icons8.com/color/96/cricket.png'),
    Channel(id: 'atn_cricket',  name: 'ATN Plus Cricket',             category: 'Cricket', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/85829.m3u8', logoUrl: 'https://img.icons8.com/color/96/cricket.png'),

    // ===== FOOTBALL =====
    Channel(id: 'tnt1',        name: 'TNT Sport 1',                   category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/23564.m3u8',  logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'tnt2',        name: 'TNT Sport 2',                   category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/23565.m3u8',  logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'tnt3',        name: 'TNT Sports 3 FHD',              category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/148090.m3u8', logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'sky_foot',    name: 'Sky Sports Football HD',        category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/150854.m3u8', logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'espn1',       name: 'ESPN 1 USA',                    category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/52.m3u8',     logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'espn2',       name: 'ESPN 2 HD USA',                 category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/53.m3u8',     logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'fs1',         name: 'Fox Sport 1 HD (FS1)',          category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/54.m3u8',     logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),
    Channel(id: 'fs2',         name: 'Fox Sport 2 HD (FS2)',          category: 'Football', streamUrl: 'http://starhub.pro/live/farhat-3379/67897-913379/55.m3u8',     logoUrl: 'https://img.icons8.com/color/96/goalkeeper.png'),

    // ===== SPORTS (Permanent CDN) =====
    Channel(id: 'caze_1080p',  name: 'Caze TV Brazil 1080p',         category: 'Sports', streamUrl: 'https://dfr80qz435crc.cloudfront.net/MNOP/Amagi/Caze/Caze_TV_BR/1080p-vtt/index.m3u8', logoUrl: 'https://img.icons8.com/color/96/sport.png'),
    Channel(id: 'caze_720p',   name: 'Caze TV Brazil 720p',          category: 'Sports', streamUrl: 'https://dfr80qz435crc.cloudfront.net/MNOP/Amagi/Caze/Caze_TV_BR/720p-vtt/index.m3u8',  logoUrl: 'https://img.icons8.com/color/96/sport.png'),
    Channel(id: 'redbull',     name: 'Red Bull TV',                  category: 'Sports', streamUrl: 'https://rbmn-live.akamaized.net/hls/live/590964/BoRB-AT/master.m3u8',                  logoUrl: 'https://img.icons8.com/color/96/sport.png'),
    Channel(id: 'dd_sports',   name: 'DD Sports',                    category: 'Sports', streamUrl: 'https://cdn-6.pishow.tv/live/13/master.m3u8',                                          logoUrl: 'https://img.icons8.com/color/96/sport.png'),
    Channel(id: 'africa24',    name: 'Africa 24 Sport',              category: 'Sports', streamUrl: 'https://africa24.vedge.infomaniak.com/livecast/ik:africa24sport/manifest.m3u8',        logoUrl: 'https://img.icons8.com/color/96/sport.png'),
    Channel(id: 'fox_sports',  name: 'Fox Sports HD',                category: 'Sports', streamUrl: 'https://1nyaler.streamhostingcdn.top/stream/26/index.m3u8',                            logoUrl: 'https://img.icons8.com/color/96/sport.png'),

    // ===== BD SPORTS =====
    Channel(id: 'gazi_tv',     name: 'Gazi TV HD',                   category: 'BD Sports', streamUrl: 'http://rgkkw.live:80/live/1Aoen7elp5/IgMJ60tmAa/767.m3u8',                        logoUrl: 'https://img.icons8.com/color/96/bangladesh.png'),
  ];

  static List<String> get categories =>
      defaultChannels.map((c) => c.category).toSet().toList()..sort();
}
