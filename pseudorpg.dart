void main() {
  var cajadoMago = Arma(dano: 22, nomearma: 'Tesseract', tipo: 'Magia');

  var espadaGuerreiro = Arma(
    dano: 48,
    nomearma: 'Bersask',
    tipo: 'Espada Longa',
  );

  var guerreiroVar = Guerreiro(
    classe: 'Guerreiro',
    nivel: 15,
    nome: 'Kratos',
    vida: 145,
    forca: 200,
    arma: espadaGuerreiro,
  );

  var magoVar = Mago(
    classe: 'Mago',
    nivel: 18,
    nome: 'Veigar',
    vida: 75,
    mana: 320,
    arma: cajadoMago,
  );

  var montariaGuerreiro = Montaria(
    nome: 'Kravosk',
    tipo: 'Lagarto Infernal',
    velocidade: 35,
  );

  var montariaMago = Montaria(
    nome: 'Vyrkus',
    tipo: 'Lula Cósmica',
    velocidade: 35,
  );

  guerreiroVar.exibirInfo();
  montariaGuerreiro.exibirInfo();
  guerreiroVar.atacar();

  magoVar.exibirInfo();
  montariaMago.exibirInfo();
  magoVar.atacar();
}

class Personagem {
  String nome;
  String classe;
  int nivel;
  int vida;
  Arma arma;

  Personagem({
    required this.classe,
    required this.nivel,
    required this.nome,
    required this.vida,
    required this.arma,
  });

  void exibirInfo({String atributoExtra = ''}) {
    print(
      '👤 Nome: $nome | Classe: $classe | Nível: $nivel | Vida: $vida$atributoExtra ',
    );
    arma.exibirInfo();
  }

  void uparNivel() {
    nivel++;
    print('Você upou :D');
  }
}

class Guerreiro extends Personagem {
  int forca;

  Guerreiro({
    required super.classe,
    required super.nivel,
    required super.nome,
    required super.vida,
    required super.arma,
    required this.forca,
  });

  @override
  void exibirInfo({String atributoExtra = ''}) {
    super.exibirInfo(atributoExtra: ' | 💪 Força: $forca');
  }

  void atacar() {
    print('🗡️ $nome atacou com sua ${arma.nomearma} !');
  }
}

class Mago extends Personagem {
  int mana;

  Mago({
    required super.classe,
    required super.nivel,
    required super.nome,
    required super.vida,
    required super.arma,
    required this.mana,
  });

  @override
  void exibirInfo({String atributoExtra = ''}) {
    super.exibirInfo(atributoExtra: ' | 🔮 Mana: $mana');
  }

  void atacar() {
    print('🔥 $nome lançou um feitiço com ${arma.nomearma} !');
  }
}

class Arma {
  String nomearma;
  int dano;
  String tipo;

  Arma({required this.dano, required this.nomearma, required this.tipo,});

  void exibirInfo() {
    print('⚔️ Arma: $nomearma | Tipo: $tipo | Dano: $dano');
  }
}

class Montaria {
  String nome;
  String tipo;
  int velocidade;

  Montaria({required this.nome, required this.tipo, required this.velocidade});

  void exibirInfo() {
    print('🐎 Montaria: $nome | Tipo: $tipo | Velocidade: $velocidade km/h');
  }
}
