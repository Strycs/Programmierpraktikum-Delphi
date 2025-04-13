{
  <summary>
  Hier wurden alle notwendigen game übergreifenden Informationen
  über Typen und Konstanten definiert.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
}
unit uBase;

interface

const
  /// <summary>Minimale Anzahl an Spielern.</summary>
  MIN_PLAYERS = 2;
  /// <summary>Maximale Anzahl an Spielern.</summary>
  MAX_PLAYERS = 4;
  /// <summary>Anzahl der Würfel im Spiel.</summary>
  NUMBER_OF_CUBES = 8;
  /// <summary>Anzahl der Karten im Spiel.</summary>
  NUMBER_OF_CARDS = 35;

  /// <summary>Minimale Anzahl an Würfeln, die für einen Wurf benötigt werden.</summary>
  MIN_CUBES_FOR_THROW = 2;
  /// <summary>Minimale Anzahl an Totenköpfen, um den Zug zu verlieren.</summary>
  MIN_SKULLS_FOR_LOST_MOVE = 3;
  /// <summary>Minimale Anzahl an Totenköpfen für einen Zug zur Totenkopfinsel.</summary>
  MIN_SKULLS_FOR_SKULL_ISLAND_MOVE = 4;

  /// <summary>Punkte, die zum Gewinnen benötigt werden.</summary>
  POINTS_FOR_WIN = 6000;

type
  /// <summary>
  /// Enumeration für die verschiedenen Seiten eines Würfels.
  /// </summary>
  TCubeSide = (csDiamond, csGoldCoin, csMonkey, csParrot, csSaber, csSkull);

  /// <summary>
  /// Menge von Würfelseiten.
  /// </summary>
  TCubeSides = set of TCubeSide;

const
  /// <summary>Menge aller Würfelseiten.</summary>
  csALL = [csDiamond, csGoldCoin, csMonkey, csParrot, csSaber, csSkull];
  /// <summary>Menge der Tier-Würfelseiten ist wichtig für gcAnimals card.</summary>
  csANIMALS = [csParrot, csMonkey];

type
  /// <summary>
  /// Typ für die ID eines Würfels.
  /// </summary>
  TCubeId = 0 .. NUMBER_OF_CUBES - 1;

  /// <summary>
  /// Menge von Würfel-IDs.
  /// </summary>
  TCubeIds = set of TCubeId;

  TCubeSideArray = array [TCubeId] of TCubeSide;

  /// <summary>Record, welcher eine Menge von Würfel-IDs und ein Array von Würfelseiten kombiniert.</summary>
  TCubeIdSides = record
    ids: TCubeIds;
    sides: TCubeSideArray;
  end;

  PCubeIdSides = ^TCubeIdSides;

const
  /// <summary>Menge aller Würfel-IDs.</summary>
  ALL_CUBE_IDS = [0 .. High(TCubeId)];

type
  /// <summary>
  /// Typ für die Anzahl der Würfel.
  /// </summary>
  TNumberOfCubes = 0 .. NUMBER_OF_CUBES;

  /// <summary>
  /// Enumeration für die verschiedenen Zustände eines Würfels.
  /// </summary>
  TCubeState = (ctSaveSaved, ctSaved, ctKilled, ctFree);

  /// <summary>
  /// Menge von Würfelzuständen.
  /// </summary>
  TCubeStates = set of TCubeState;

const
  /// <summary>Menge aller Würfelzustände.</summary>
  ctALL = [ctSaveSaved, ctSaved, ctKilled, ctFree];

  /// <summary>Menge aller nicht-getöteten Würfelzustände.</summary>
  ctNOTKILLED = [ctSaveSaved, ctSaved, ctFree];

  /// <summary>Menge aller gespeicherten Würfelzustände.</summary>
  ctALLSAVED = [ctSaveSaved, ctSaved];

type
  /// <summary>
  /// Typ für die ID einer Karte.
  /// </summary>
  TCardId = 0 .. NUMBER_OF_CARDS - 1;

  /// <summary>
  /// Enumeration für die verschiedenen Spielkarten.
  /// </summary>
  TGameCard = (gcAnimals, gcDiamond, gcGoldCoin, gcGuardian, gcPirate, gcPirateShip2, gcPirateShip3, gcPirateShip4, gcSkull1,
    gcSkull2, gcTreasureIsland);

  /// <summary>
  /// Typ für die ID eines Spielers.
  /// </summary>
  TPlayerId = 0 .. MAX_PLAYERS - 1;

  /// <summary>Typ für die Anzahl maximalen Spieler.</summary>
  TMaxPlayers = 0 .. MAX_PLAYERS;

  /// <summary>Typ für die Anzahl aktiver Spieler.</summary>
  TActivePlayers = MIN_PLAYERS .. MAX_PLAYERS;

  /// <summary>Array der Spielernamen.</summary>
  TPlayerNames = array [TPlayerId] of string;

  /// <summary>Enumeration für die verschiedenen Zugmodi.</summary>
  TMoveMode = (mmNormal, mmSkullIsland, mmPirateShip);

  /// <summary>
  /// Typ für die Piratenschiff-Spielkarten und den moveMode mmPirateShip der durch sein Verhalten und seine Punkteberechnung speziell ist.
  /// </summary>
  TPirateShipGameCard = gcPirateShip2 .. gcPirateShip4;

const

  /// <summary>Array für die Punkte einer Kombination, indiziert durch die Anzahl der gleichen Würfelseiten.</summary>
  COMBINATION_POINTS: array [TNumberOfCubes] of integer = (0, 0, 0, 100, 200, 500, 1000, 2000, 4000);

  /// <summary>Array für die Punkte einer einzelnen Würfelseite.</summary>
  SIDE_POINTS: array [TCubeSide] of integer = (100, 100, 0, 0, 0, -100);

  /// <summary>Bonus-Punkte für die Schatztruhe,d.h. alle 8 Würfel punkten und kein Skull auch nicht durch eine Karte</summary>
  TREASURE_CHEST_BONUS = 500;

  /// <summary>
  /// Array für die Anzahl zusätzlicher CubeSides einer Karte.
  /// Relevant in der Berechnung der Punkte sowie bei skulls zum forcierten beenden des Moves
  /// </summary>
  ADD_CUBES_CARDS: array [TGameCard] of integer = (0, 1, 1, 0, 0, 0, 0, 0, 1, 2, 0);

  /// <summary>Array für die CubeSide je nach karte </summary>
  ADD_CUBES_CARDS_SIDES: array [TGameCard] of TCubeSide = (csMonkey, csDiamond, csGoldCoin, csMonkey, csMonkey, csMonkey,
    csMonkey, csMonkey, csSkull, csSkull, csMonkey);

  /// <summary>Menge aller verschiedenen Piratenschiff-Karten.</summary>
  ALL_PIRATESHIPS = [gcPirateShip2 .. gcPirateShip4];

  /// <summary>notwendige Anzahl der Säbel im moveMode mmPirateShip</summary>
  PIRATESHIP_SABERS: array [TPirateShipGameCard] of integer = (2, 3, 4);
  /// <summary>Kartenboni im moveMode mmPirateShip</summary>
  PIRATESHIP_POINTS: array [TPirateShipGameCard] of integer = (300, 500, 1000);

const

  /// <summary>Array mit Kurzbezeichnungen für die Würfelseiten.</summary>
  CUBE_SIDE_SHORTS: array [TCubeSide] of string = ('DMT', 'GLC', 'MKY', 'PRT', 'SBR', 'SKL');

  /// <summary>Array mit den Bezeichnungen für die Karten.</summary>
  CARD_SIDE_LONGS: array [TGameCard] of string = ('Tiere', 'Diamant', 'Goldm'#252'nze', 'W'#228'chterin', 'Pirat',
    'Piratenschiff2', 'Piratenschiff3', 'Piratenschiff4', 'Totenkopf1', 'Totenkopf2', 'Schatzinsel');

  /// <summary>Array mit ausführlichen Beschreibungen der Karten.</summary>
  CARD_INFO_TEXTS: array [TGameCard] of string =
    ('Tiere: Gew'#252'rfelte Affen und '#13#10'Papageien z'#228'hlen zusammen '#13#10'als eine Kombination.'#13#10'Daher sind beispielsweise zwei '#13#10'Papageien und drei Affen eine '#13#10'5er Kombination.',
    'Diamant: Die Kaperfahrt '#13#10'beginnt'#13#10'mit einem Diamanten, der f'#252'r '#13#10'den'#13#10'Spieler sowohl einzeln als '#13#10'auch in'#13#10'einer Kombination mit den '#13#10'W'#252'rfeln'#13#10'Punkte z'#228'hlt',
    'Goldm'#252'nze: Die Kaperfahrt'#13#10'beginnt mit einer Goldm'#252'nze,'#13#10'die f'#252'r den Spieler sowohl'#13#10'einzeln als auch in einer'#13#10'Kombination mit den W'#252'rfeln'#13#10'Punkte z'#228'hlt.',
    'W'#228'chterin: Der Spieler darf'#13#10'einmalig w'#228'hrend seiner'#13#10'Kaperfahrt einen gew'#252'rfelten'#13#10'Totenkopf erneut w'#252'rfeln. In'#13#10'diesem Fall darf ein W'#252'rfel mit'#13#10'Totenkopf auch einzeln'#13#10'gew'#252'rfelt'#13#10'werden.',
    'Pirat: Die erzielten Punkte bei '#13#10'dieser Kaperfahrt werden '#13#10'verdoppelt. Muss der Spieler '#13#10'zur Totenkopfinsel fahren,'#13#10'verlieren die Mitspieler'#13#10'200 Punkte f'#252'r'#13#10'jedenTotenkopf.',
    'Piratenschiff: Der Spieler muss '#13#10'mindestens die abgebildete '#13#10'Zahl an S'#228'beln w'#252'rfeln und '#13#10'seine Kaperfahrt freiwillig '#13#10'beenden. Dann erh'#228'lt er zu '#13#10'seinem W'#252'rfelergebnis '#13#10'(gew'#252'rfelte S'#28'bel z'#228'hlen als '#13#10'Kombination) zus'#228'tzlich die '#13#10'unten abgebildete Zahl als '#13#10'Bonus. Andernfalls z'#228'hlt das '#13#10'W'#252'rfelergebnis null Punkte '#13#10'und die Zahl auf der Karte '#13#10'wird ihm von seiner Punktzahl '#13#10'auf dem Punkteblock '#13#10'abgezogen. ',
    'Piratenschiff: Der Spieler muss '#13#10'mindestens die abgebildete '#13#10'Zahl an S'#228'beln w'#252'rfeln und '#13#10'seine Kaperfahrt freiwillig '#13#10'beenden. Dann erh'#228'lt er zu '#13#10'seinem W'#252'rfelergebnis '#13#10'(gew'#252'rfelte S'#28'bel z'#228'hlen als '#13#10'Kombination) zus'#228'tzlich die '#13#10'unten abgebildete Zahl als '#13#10'Bonus. Andernfalls z'#228'hlt das '#13#10'W'#252'rfelergebnis null Punkte '#13#10'und die Zahl auf der Karte '#13#10'wird ihm von seiner Punktzahl '#13#10'auf dem Punkteblock '#13#10'abgezogen. ',
    'Piratenschiff: Der Spieler muss '#13#10'mindestens die abgebildete '#13#10'Zahl an S'#228'beln w'#252'rfeln und '#13#10'seine Kaperfahrt freiwillig '#13#10'beenden. Dann erh'#228'lt er zu '#13#10'seinem W'#252'rfelergebnis '#13#10'(gew'#252'rfelte S'#28'bel z'#228'hlen als '#13#10'Kombination) zus'#228'tzlich die '#13#10'unten abgebildete Zahl als '#13#10'Bonus. Andernfalls z'#228'hlt das '#13#10'W'#252'rfelergebnis null Punkte '#13#10'und die Zahl auf der Karte '#13#10'wird ihm von seiner Punktzahl '#13#10'auf dem Punkteblock '#13#10'abgezogen. ',
    'Totenkopf: Die Kaperfahrt '#13#10'beginnt je nach Karte mit '#13#10'einem'#13#10'oder zwei Totenk'#246'pfen. Diese '#13#10'werden zu den gew'#252'rfelten '#13#10'Totenk'#246'pfen hinzugez'#228'hlt. Der '#13#10'Spieler erh'#228'lt keinen Bonus '#13#10'und f'#228'hrt schneller zur '#13#10'Totenkopfinsel.',
    'Totenkopf: Die Kaperfahrt '#13#10'beginnt je nach Karte mit '#13#10'einem'#13#10'oder zwei Totenk'#246'pfen. Diese '#13#10'werden zu den gew'#252'rfelten '#13#10'Totenk'#246'pfen hinzugez'#228'hlt. Der '#13#10'Spieler erh'#228'lt keinen Bonus '#13#10'und f'#228'hrt schneller zur '#13#10'Totenkopfinsel.',
    'Schatzinsel: Nach einem Wurf ' + 'darf der Spieler einen oder ' + 'mehrere W'#252'rfel auf diese ' +
    'Karte legen. Er darf dort ' + 'liegende W'#252'rfel auch wieder ' + 'herunternehmen und erneut ' +
    'w'#252'rfeln. Wirft der Spieler ' + 'einen dritten Totenkopf, endet' + 'seine Kaperfahrt und er darf ' +
    'auch keinen W'#252'rfel aus ' + 'diesem ' + 'Wurf auf die Karte legen. ' + 'Nur die Punkte der W'#252'rfel, die ' +
    'schon auf der Karte liegen, ' + 'werden notiert.');

implementation

end.
