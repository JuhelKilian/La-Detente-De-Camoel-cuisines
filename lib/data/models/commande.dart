class Commande {
  final int idCommande;
  final int? idClient;
  final int? idReserv;
  final String? commentaireClient;
  final int idTable;
  final List<InstancePlat> instancePlats;

  Commande({
    required this.idCommande,
    this.idClient,
    this.idReserv,
    this.commentaireClient,
    required this.idTable,
    required this.instancePlats,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      idCommande: json['IDCOMMANDE'],
      idClient: json['IDCLIENT'],
      idReserv: json['IDRESERV'],
      commentaireClient: json['COMMENTAIRECLIENT'],
      idTable: json['IDTABLE'],
      instancePlats: (json['instance_plats'] as List)
          .map((p) => InstancePlat.fromJson(p))
          .toList(),
    );
  }
}

class InstancePlat {
  final int idCommande;
  final int idInstance;
  final int idPlat;
  final int idEtat;
  final EtatPlat etatplat;
  final Plat plat;

  InstancePlat({
    required this.idCommande,
    required this.idInstance,
    required this.idPlat,
    required this.idEtat,
    required this.etatplat,
    required this.plat,
  });

  factory InstancePlat.fromJson(Map<String, dynamic> json) {
    return InstancePlat(
      idCommande: json['IDCOMMANDE'],
      idInstance: json['IDINSTANCE'],
      idPlat: json['IDPLAT'],
      idEtat: json['IDETAT'],
      etatplat: EtatPlat.fromJson(json['etatplat']),
      plat: Plat.fromJson(json['plat']),
    );
  }
}

class EtatPlat {
  final int idEtat;
  final String libelleEtat;

  EtatPlat({required this.idEtat, required this.libelleEtat});

  factory EtatPlat.fromJson(Map<String, dynamic> json) {
    return EtatPlat(
      idEtat: json['IDETAT'],
      libelleEtat: json['LIBELLEETAT'],
    );
  }
}

class Plat {
  final int idPlat;
  final String libellePlat;
  final double prixPlatHt;
  final String? lienImg;
  final TypePlat typeplat;

  Plat({
    required this.idPlat,
    required this.libellePlat,
    required this.prixPlatHt,
    this.lienImg,
    required this.typeplat,
  });

  factory Plat.fromJson(Map<String, dynamic> json) {
    return Plat(
      idPlat: json['IDPLAT'],
      libellePlat: json['LIBELLEPLAT'],
      prixPlatHt: json['PRIXPLATHT'].toDouble(),
      lienImg: json['LIENIMG'],
      typeplat: TypePlat.fromJson(json['typeplat']),
    );
  }
}

class TypePlat {
  final int idTypePlat;
  final String typePlat;

  TypePlat({required this.idTypePlat, required this.typePlat});

  factory TypePlat.fromJson(Map<String, dynamic> json) {
    return TypePlat(
      idTypePlat: json['IDTYPEPLAT'],
      typePlat: json['TYPEPLAT'],
    );
  }
}
