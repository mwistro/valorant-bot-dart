import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:dotenv/dotenv.dart';
import 'package:valorant_bot/rank_data.dart';

final env = DotEnv()..load();
final apiKey = {'Authorization': 'YOUR-HDEV-APIKEY-HERE'};
final String botToken = 'YOUR-BOT-TOKEN-HERE';
final commands = CommandsPlugin(
  prefix: (m) => '/',
  guild: Snowflake.parse('YOUR-SERVER-ID-HERE'),
);

void main() async {
  final bot = await Nyxx.connectGateway(
    botToken,
    GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
    options: GatewayClientOptions(plugins: [commands]),
  );

  bot.onReady.listen((event) async {
    final user = await event.gateway.client.user.fetch();
    print('✅ Bot está online como ${user.username}#${user.discriminator}');
  });

  // /Perfil
  commands.addCommand(
    ChatCommand(
      'perfil',
      'Busque informações básicas de perfis de valorant',
      id('perfil', (
        ChatContext context,
        String playerName,
        String playerTag,
      ) async {
        final nameValue = playerName.trim();
        final tagValue = playerTag.trim();

        await context.respond(
          MessageBuilder(
            content: '🔍 Buscando perfil de `$nameValue#$tagValue`...',
          ),
        );

        await perfilCommand(nameValue, tagValue, context);
      }),
    ),
  );

  commands.addCommand(
    ChatCommand(
      'stats',
      'Busque stats de um player baseado nas suas últimas 10 partidas',
      id('stats', (
        ChatContext context,
        String playerName,
        String playerTag,
      ) async {
        final nameValue = playerName.trim();
        final tagValue = playerTag.trim();

        await context.respond(
          MessageBuilder(
            content: '🔍 Buscando stats de `$nameValue#$tagValue`...',
          ),
        );
        final profileStats = await getProfileStats(
          nameValue,
          tagValue,
          context,
        );
        final regionParameter = profileStats['parameter'];

        await statsCommand(nameValue, tagValue, regionParameter, context);
      }),
    ),
  );

  commands.addCommand(
    ChatCommand(
      'historico',
      'Busque o histórico das últimas 10 partidas do player',
      id('historico', (
        ChatContext context,
        String playerName,
        String playerTag,
      ) async {
        final nameValue = playerName.trim();
        final tagValue = playerTag.trim();

        await context.respond(
          MessageBuilder(
            content: '🔍 Buscando histórico de `$nameValue#$tagValue`...',
          ),
        );
        final profileStats = await getProfileStats(
          nameValue,
          tagValue,
          context,
        );
        final region = profileStats['parameter'];

        final mostPlayed = await getMostPlayedAgent(
          nameValue,
          region,
          tagValue,
        );
        final datamatchList = mostPlayed['datampAgent'];

        await historicoCommand(datamatchList, nameValue, context);
      }),
    ),
  );
}

String getRankColor(String rankVar) {
  final rankSplit = rankVar.split(' ').first;
  final colorCode = rankcolorMap[rankSplit] ?? '#7a7a7a';
  return colorCode;
}

Future<Map<String, dynamic>> getMostPlayedAgent(
  String nickname,
  String regionParameter,
  String tag,
) async {
  var urlmpAgent = Uri.parse(
    'https://api.henrikdev.xyz/valorant/v3/matches/$regionParameter/$nickname/$tag?size=10&mode=competitive',
  );

  var responsempAgent = await http.get(urlmpAgent, headers: apiKey);
  var datampAgent = jsonDecode(responsempAgent.body)['data'];

  if (datampAgent.isEmpty) {
    urlmpAgent = Uri.parse(
      'https://api.henrikdev.xyz/valorant/v3/matches/$regionParameter/$nickname/$tag?size=10',
    );
    responsempAgent = await http.get(urlmpAgent, headers: apiKey);
    datampAgent = jsonDecode(responsempAgent.body)['data'];
  }
  final listTest = [];
  for (var i = 0; i < datampAgent.length; i++) {
    final mpagentList =
        datampAgent != null
            ? datampAgent[i]['players']['all_players']
            : 'Nao deu agent';
    for (var i = 0; i < mpagentList.length; i++) {
      final matchMap = mpagentList[i];
      final nameMap = matchMap['name'];
      final agentMap = matchMap['character'];
      if (nameMap.toString().toLowerCase() ==
          nickname.toString().toLowerCase()) {
        listTest.add(agentMap);
      }
    }
  }
  var agentCounter = {};

  listTest.forEach((agent) {
    if (!agentCounter.containsKey(agent)) {
      agentCounter[agent] = 1;
    } else {
      agentCounter[agent] += 1;
    }
  });

  var mostplayedFinal = agentCounter.entries.reduce((a, b) {
    return a.value > b.value ? a : b;
  });

  final emoji = agentEmojis['${mostplayedFinal.key}Icon'] ?? '';

  return {
    'mostplayed': mostplayedFinal.key,
    'emoji': emoji,
    'datampAgent': datampAgent,
  };
}

Future<Map<String, dynamic>> getRankStat(
  String regionParameter,
  String nickname,
  String tag,
) async {
  final urlRank = Uri.parse(
    'https://api.henrikdev.xyz/valorant/v2/mmr/$regionParameter/$nickname/$tag',
  );
  final responseRank = await http.get(urlRank, headers: apiKey);
  final dataRank = jsonDecode(responseRank.body)['data'];

  final rankVar =
      dataRank != null
          ? dataRank['current_data']['currenttierpatched']
          : 'Unranked';

  final iconUrl = rankIcons[rankVar] ?? rankIcons['Unranked'];

  return {'rank': rankVar, 'icon': iconUrl};
}

Future<Map<String, dynamic>> getProfileStats(
  String nickname,
  String tag,
  ChatContext context,
) async {
  final url = Uri.parse(
    'https://api.henrikdev.xyz/valorant/v1/account/$nickname/$tag',
  );

  final response = await http.get(url, headers: apiKey);
  final data = jsonDecode(response.body)['data'];

  //                   [{/perfil}, {Prome}, {Moedas#4556}]

  if (data == null) {
    final errorList = jsonDecode(response.body)['errors'];
    print(errorList);
    for (var i = 0; i < errorList.length; i++) {
      if (errorList[i]['code'] == 22) {
        await context.respond(
          MessageBuilder()
            ..content = '❌ Perfil não encontrado. Verifique o nome e a tag.',
        );
      } else if (errorList[i]['code'] == 24) {
        await context.respond(
          MessageBuilder()
            ..content = '❌ Perfil inativo. Dados indisponíveis no momento.',
        );
      }
    }
  }

  final nameVar = data['name'];
  final regionVar = data['region'].toString().toUpperCase();
  final levelVar = data['account_level'];
  final cardimageVar = data['card']['wide'];
  final regionParameter = data['region'];

  return {
    'name': nameVar,
    'region': regionVar,
    'level': levelVar,
    'card': cardimageVar,
    'parameter': regionParameter,
  };
}

Future<Map<String, dynamic>> getkdStats(
  List dataMatchlist,
  String nickname,
) async {
  var totalKills = 0;
  var totalDeaths = 0;
  var totalAssists = 0;
  var totalbShots = 0;
  var totalhShots = 0;
  var totallShots = 0;
  List playerKDA = [];
  for (var match in dataMatchlist) {
    final playerlistVar = match['players']['all_players'];
    for (var player in playerlistVar) {
      final playerName = player['name'];
      if (playerName.toString().toLowerCase() ==
          nickname.toString().toLowerCase()) {
        int playerKills = player['stats']['kills'];
        int playerDeaths = player['stats']['deaths'];
        int playerAssists = player['stats']['assists'];
        int playerbShots = player['stats']['bodyshots'];
        int playerhShots = player['stats']['headshots'];
        int playerlShots = player['stats']['legshots'];

        playerKDA.add('$playerKills/$playerDeaths/$playerAssists');
        totalKills += playerKills;
        totalDeaths += playerDeaths;
        totalAssists += playerAssists;
        totalbShots += playerbShots;
        totalhShots += playerhShots;
        totallShots += playerlShots;
      }
    }
  }
  // Calculations
  final kdDouble = totalKills / totalDeaths;
  final totalShots = totalbShots + totalhShots + totallShots;
  final headshotCalc = (totalhShots / totalShots) * 100;
  final hsPercentage = headshotCalc.toStringAsFixed(2);

  // Results
  final kdFinal = kdDouble.toStringAsFixed(2);
  final totalKDA = '$totalKills/$totalDeaths/$totalAssists';

  /*print(' kills: $totalKills');
  print('deaths: $totalDeaths');
  print('assists: $totalAssists');
  print('bodyshots: $totalbShots');
  print('headshots: $totalhShots');
  print('legshots: $totallShots');*/
  return {
    'kd': kdFinal,
    'totalkda': totalKDA,
    'hspercentage': hsPercentage,
    'playerkda': playerKDA,
  };
}

Future<List<dynamic>> getMatchHistory(
  List dataMatchlist,
  String nickname,
) async {
  var playerTeam;
  var playedAgent;
  var playedMap;
  var playedMode;
  var playerKda;
  var winCheck;
  List matchDetails = [];
  for (var match in dataMatchlist) {
    playedMap = match['metadata']['map'];
    playedMode = match['metadata']['mode'];
    final playerlistVar = match['players']['all_players'];
    for (var player in playerlistVar) {
      final playerName = player['name'];
      if (playerName.toString().toLowerCase() ==
          nickname.toString().toLowerCase()) {
        playerTeam = player['team'].toString().toLowerCase();
        playedAgent = player['character'];
        playerKda =
            '${player['stats']['kills']}/${player['stats']['deaths']}/${player['stats']['assists']}';
        break;
      }
    }
    winCheck = match['teams']['$playerTeam']['has_won'] != true ? '✅ ' : '❌';
    matchDetails.add(
      '$winCheck | $playedMap | $playedMode | $playerKda | $playedAgent ${agentEmojis['${playedAgent}Icon']}',
    );
  }
  return matchDetails;
}

Future<void> perfilCommand(
  String nickname,
  String tag,
  ChatContext context,
) async {
  // Get the base profile stats
  final profileStats = await getProfileStats(nickname, tag, context);
  final nameVar = profileStats['name'];
  final regionVar = profileStats['region'];
  final levelVar = profileStats['level'];
  final cardimageVar = profileStats['card'];
  final regionParameter = profileStats['parameter'];

  // Get rank stats and colors/icons
  final rankInfo = await getRankStat(regionParameter, nickname, tag);
  final rankVar = rankInfo['rank'];
  final iconUrl = rankInfo['icon'];
  final colorHex = getRankColor(rankVar);

  // Runs the output embeded
  await context.respond(
    MessageBuilder()
      ..embeds = [
        EmbedBuilder()
          ..title = '''
👤 Player: $nameVar #$tag
🌍 Região: $regionVar
🔢 Nível: $levelVar
'''
          ..image = EmbedImageBuilder(url: Uri.parse(cardimageVar))
          ..color = DiscordColor.parseHexString('#ff4655'),

        EmbedBuilder()
          ..title = '🏅 Rank: $rankVar'
          ..thumbnail = EmbedThumbnailBuilder(url: Uri.parse(iconUrl))
          ..color = DiscordColor.parseHexString(colorHex),
      ],
  );
}

Future<void> statsCommand(
  String nickname,
  String tag,
  String regionParameter,
  ChatContext context,
) async {
  // Get the most played agent of the last 10 matches
  final mostplayedFunction = await getMostPlayedAgent(
    nickname,
    regionParameter,
    tag,
  );
  final profileStats = await getProfileStats(nickname, tag, context);
  final cardimageVar = profileStats['card'];
  final emoji = mostplayedFunction['emoji'];
  final mostplayedFinal = mostplayedFunction['mostplayed'];
  final dataMatchlist = mostplayedFunction['datampAgent'];
  final playerStats = await getkdStats(dataMatchlist, nickname);
  final kdFinal = playerStats['kd'];
  final totalKDA = playerStats['totalkda'];
  final hsPercent = playerStats['hspercentage'];
  final getRank = await getRankStat(regionParameter, nickname, tag);
  final iconUrl = getRank['icon'];

  await context.respond(
    MessageBuilder()
      ..embeds = [
        EmbedBuilder()
          ..description = '''
             📊 **Estatísticas das últimas 10 partidas de $nickname** 📊 '''
          ..image = EmbedImageBuilder(url: Uri.parse(cardimageVar))
          ..color = DiscordColor.parseHexString('#ff4655'),

        EmbedBuilder()
          ..description = '''
**📊 KDA Total: $totalKDA** 
**🎯 K/D: $kdFinal**   
**🎯 HS%: $hsPercent%**  
**🔥 Agente mais jogado: $mostplayedFinal** $emoji
'''
          ..thumbnail = EmbedThumbnailBuilder(url: Uri.parse(iconUrl)),
      ],
  );
}

Future<void> historicoCommand(
  List dataMatchlist,
  String nickname,
  ChatContext context,
) async {
  final matchDetails = await getMatchHistory(dataMatchlist, nickname);

  await context.respond(
    MessageBuilder()
      ..embeds = [
        EmbedBuilder()
          ..title = '🕹️ Histórico das últimas 10 partidas de $nickname'
          ..description = matchDetails.join('\n\n')
          ..color = DiscordColor.parseHexString('#ff4655'),
      ],
  );
}

//FUNÇÃO COM REQUESTS
