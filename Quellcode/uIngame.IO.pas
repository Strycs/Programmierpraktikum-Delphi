{
  <summary>
  Ist für das Laden und Speichern des Spiels zuständig
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
}
unit uIngame.IO;

interface

uses
  sysutils,
  uBase,
  uIngame.Players,
  uIngame.Cards;

/// <summary>
/// Repräsentiert die Spielstruktur, die die Anzahl der Spieler, den aktuellen Spieler,
/// die Spielerstatistiken und den Kartenstapel enthält.
/// </summary>
type
  TGameStructure = record
    numberOfPlayers: TActivePlayers;
    currentPlayerId: TPlayerId;
    playerStats: TAllStats;
    cardStack: TCardStack;
  end;

const
  /// <summary>
  /// Kein Fehler.
  /// </summary>
  ERR_NO_ERROR = 0;
  /// <summary>
  /// Leeres Token.
  /// </summary>
  ERR_EMPTY_TOKEN = -1;
  /// <summary>
  /// Token enthält keine gültige Zahl.
  /// </summary>
  ERR_NO_NUMBER = -2;
  /// <summary>
  /// Wert liegt außerhalb des erlaubten Bereichs.
  /// </summary>
  ERR_RANGE = -3;
  /// <summary>
  /// Unerwartetes Dateiende.
  /// </summary>
  ERR_EOF = -4;
  /// <summary>
  /// Unerwartetes Token.
  /// </summary>
  ERR_UNEXPECTED_TOKEN = -5;
  /// <summary>
  /// Datei existiert bereits.
  /// </summary>
  ERR_FILE_EXISTS = -6;

  /// <summary>
  /// Repräsentiert einen Fehler beim Ein-/Auslesen einer Datei.
  /// </summary>
type
  TIngameIOError = record
    Code: Integer;
    line: Integer;
  end;

  /// <summary>
  /// Speichert die Spielstruktur in eine Datei.
  /// Schreibt die Anzahl der Spieler, den aktuellen Spieler, die Spielerstatistiken und den Kartenstapel in die Datei.
  /// </summary>
  /// <param name="fName">Der Dateiname, in den gespeichert werden soll.</param>
  /// <param name="gameStructure">Die zu speichernde Spielstruktur.</param>
  /// <returns>Ein TIngameIOError, der den Fehlercode und die Zeilennummer enthält.</returns>
function saveToFile(fName: String; gameStructure: TGameStructure): TIngameIOError;

/// <summary>
/// Lädt eine Spielstruktur aus einer Datei.
/// Liest die Anzahl der Spieler, den aktuellen Spieler, die Spielerstatistiken und den Kartenstapel aus der Datei.
/// </summary>
/// <param name="fName">Der Dateiname, aus dem geladen werden soll.</param>
/// <param name="gameStructure">Die Variable, in die die geladene Spielstruktur geschrieben wird.</param>
/// <returns>Ein TIngameIOError, der den Fehlercode und die Zeilennummer enthält.</returns>
function loadFromFile(fName: string; var gameStructure: TGameStructure): TIngameIOError;

/// <summary>
/// Liest alle Tokens aus einer Zeile, die durch Kommata getrennt sind, und fügt sie zu einem Token zusammen.
/// </summary>
/// <param name="str">Der Eingabestring, aus dem das Token gelesen wird.</param>
/// <param name="token">Der resultierende zusammengesetzte Token.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
function greedyToken(var str: string; var token: string): Integer;

implementation

/// <summary>
/// Liest ein einzelnes Token aus einem String. Ein Token ist entweder der Teil des Strings vor
/// dem ersten Komma oder der gesamte String, wenn kein Komma vorhanden ist.
/// </summary>
/// <param name="str">Der Eingabestring, aus dem das Token gelesen wird.</param>
/// <param name="token">Der gelesene Token.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
function readToken(var str: string; var token: string): Integer;
var
  err: Integer;
  commaPos: Integer;
begin
  err := ERR_NO_ERROR;

  if str = '' then
    err := ERR_EMPTY_TOKEN;

  if err = ERR_NO_ERROR then
  begin
    commaPos := pos(',', str);
    if commaPos <> 0 then
    begin
      token := copy(str, 1, commaPos - 1);
      delete(str, 1, commaPos);
    end
    else
    begin
      token := str;
      str := '';
    end;
  end;
  readToken := err;
end;

function greedyToken(var str: string; var token: string): Integer;
var
  temp: string;
  err: Integer;
begin
  token := '';
  err := ERR_NO_ERROR;

  if str = '' then
    err := ERR_EMPTY_TOKEN;
  if err = ERR_NO_ERROR then
    while pos(',', str) <> 0 do
    begin
      err := readToken(str, temp);
      if token <> '' then
        token := token + ',';
      token := token + temp;
    end;
  greedyToken := err;
end;

/// <summary>
/// Liest ein Token und prüft ob er eine valiede Zahl ist.
/// </summary>
/// <param name="str">Der Eingabestring, aus dem das Token gelesen wird.</param>
/// <param name="token">Der resultierende Integer-Wert.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
function readIntToken(var str: string; var token: Integer): Integer;
var
  strToken: string;
  valErr: Integer;
  err: Integer;
begin
  err := readToken(str, strToken);
  if err = ERR_NO_ERROR then
  begin
    val(strToken, token, valErr);
    if valErr <> 0 then
      err := ERR_NO_NUMBER;
  end;
  readIntToken := err;
end;

/// <summary>
/// Liest ein Token als Integer und überprüft, ob es innerhalb eines bestimmten Bereichs liegt.
/// </summary>
/// <param name="str">Der Eingabestring, aus dem das Token gelesen wird.</param>
/// <param name="token">Der resultierende Integer-Wert.</param>
/// <param name="min">Das Minimum des erlaubten Bereichs.</param>
/// <param name="max">Das Maximum des erlaubten Bereichs.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
function readTestedToken(var str: string; var token: Integer; min, max: Integer): Integer;
var
  err: Integer;
begin
  err := readIntToken(str, token);
  if err = ERR_NO_ERROR then
    if not((token >= min) and (token <= max)) then
      err := ERR_RANGE;
  readTestedToken := err;
end;

function saveToFile(fName: String; gameStructure: TGameStructure): TIngameIOError;
var
  err: TIngameIOError;
  fHandle: TextFile;
  id: Integer;
begin
  err.Code := ERR_NO_ERROR;
  err.line := 0;
  try
    AssignFile(fHandle, fName);
{$I-}
    Rewrite(fHandle);
    err.Code := IOResult;
{$I-}
    if err.Code = ERR_NO_ERROR then
      with gameStructure do
      begin
{$I-}
        inc(err.line);
        writeln(fHandle, numberOfPlayers);
        err.Code := IOResult;

        if err.Code = ERR_NO_ERROR then
        begin
          inc(err.line);
          writeln(fHandle, currentPlayerId + 1);
          err.Code := IOResult;
        end;

        for id := 0 to numberOfPlayers - 1 do
          if err.Code = ERR_NO_ERROR then
          begin
            inc(err.line);
            writeln(fHandle, playerStats[id].name, ',', playerStats[id].Points);
            err.Code := IOResult;
          end;

        if err.Code = ERR_NO_ERROR then
          inc(err.line);
        for id := 0 to NUMBER_OF_CARDS - 1 do
        begin
          if err.Code = ERR_NO_ERROR then
          begin
            if id <> 0 then
              write(fHandle, ',');
            write(fHandle, ord(cardStack[id]));
            err.Code := IOResult;
          end;
        end;
      end;
  finally
    close(fHandle);

{$I-}
    if err.Code = ERR_NO_ERROR then
      err.line := 0;
    saveToFile := err;
  end;
end;

function loadFromFile(fName: string; var gameStructure: TGameStructure): TIngameIOError;

  function readLine(const fileHandle: TextFile; var str: string): Integer;
  var
    err: Integer;
  begin
    err := ERR_NO_ERROR;
    if eof(fileHandle) then
      err := ERR_EOF;
    if err = ERR_NO_ERROR then
      readln(fileHandle, str);

    readLine := err;
  end;

/// <summary>
/// Liest die Anzahl der Spieler aus der Datei und überprüft, ob sie im erlaubten Bereich liegt.
/// </summary>
/// <param name="fileHandle">Der geöffnete Datei-Handle.</param>
/// <param name="numOfPlayers">Die gelesene Anzahl der Spieler.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
  function readNumberOfPlayers(const fileHandle: TextFile; var numOfPlayers: TActivePlayers): Integer;
  var
    str: string;
    num: Integer;
    err: Integer;
  begin
    num := 0;
    err := ERR_NO_ERROR;

    err := readLine(fileHandle, str);

    if err = ERR_NO_ERROR then
      err := readTestedToken(str, num, MIN_PLAYERS, MAX_PLAYERS);

    if err = ERR_NO_ERROR then
      numOfPlayers := num;

    if err = ERR_NO_ERROR then
      if str <> '' then
        err := ERR_UNEXPECTED_TOKEN;

    readNumberOfPlayers := err;
  end;

/// <summary>
/// Liest den aktuellen Spieler aus der Datei und überprüft, ob der Wert im gültigen Bereich liegt.
/// </summary>
/// <param name="fileHandle">Der geöffnete Datei-Handle.</param>
/// <param name="currentPlayerId">Der gelesene aktuelle Spieler (minus eins, da intern 0-basiert).</param>
/// <param name="numOfPlayers">Die Anzahl der Spieler zur Validierung.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
  function readCurrentPlayer(const fileHandle: TextFile; var currentPlayerId: TPlayerId; numOfPlayers: TActivePlayers): Integer;
  var
    str: string;
    num: Integer;
    err: Integer;
  begin
    num := 0;
    err := ERR_NO_ERROR;

    err := readLine(fileHandle, str);

    if err = ERR_NO_ERROR then
      err := readTestedToken(str, num, 1, numOfPlayers);

    if err = ERR_NO_ERROR then
      currentPlayerId := num - 1; { TODO -oMS -cissue : clean dokumentation that in writing currentPlayerId +1 }

    if err = ERR_NO_ERROR then
      if str <> '' then
        err := ERR_UNEXPECTED_TOKEN;

    readCurrentPlayer := err;
  end;

/// <summary>
/// Liest die Daten eines Spielers aus der Datei, inklusive Name und Punkte.
/// </summary>
/// <param name="fileHandle">Der geöffnete Datei-Handle.</param>
/// <param name="player">Die Struktur, in die die Spieldaten geschrieben werden.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
  function readPlayer(const fileHandle: TextFile; var player: TPlayerStat): Integer;
  var
    str: string;
    err: Integer;
  begin
    str := '';
    err := ERR_NO_ERROR;

    if err = ERR_NO_ERROR then
      with player do
      begin
        if err = ERR_NO_ERROR then
          err := readLine(fileHandle, str);

        if err = ERR_NO_ERROR then
          err := greedyToken(str, name);

        if err = ERR_NO_ERROR then
          err := readTestedToken(str, Points, low(Integer), POINTS_FOR_WIN - 1);
      end;

    if err = ERR_NO_ERROR then
      if str <> '' then
        err := ERR_UNEXPECTED_TOKEN;

    readPlayer := err;
  end;

/// <summary>
/// Liest den Kartenstapel aus der Datei und wandelt jeden Kartenwert in eine Spielkarte um.
/// </summary>
/// <param name="fileHandle">Der geöffnete Datei-Handle.</param>
/// <param name="cardStack">Der aus der Datei gelesene Kartenstapel.</param>
/// <returns>Ein Integer, der einen Fehlercode darstellt.</returns>
  function readCardStack(const fileHandle: TextFile; var cardStack: TCardStack): Integer;
  var
    cardId: TCardId;
    err: Integer;
    str: string;
    num: Integer;
  begin
    err := ERR_NO_ERROR;
    err := readLine(fileHandle, str);
    if err = ERR_NO_ERROR then
      for cardId := 0 to high(TCardId) do
      begin
        if err = ERR_NO_ERROR then
          err := readTestedToken(str, num, ord(Low(TGameCard)), ord(High(TGameCard)));

        if err = ERR_NO_ERROR then
          cardStack[cardId] := TGameCard(num);
      end;

    if err = ERR_NO_ERROR then
      if str <> '' then
        err := ERR_UNEXPECTED_TOKEN;

    readCardStack := err;
  end;

var
  fileHandle: TextFile;
  err: TIngameIOError;
  id: TPlayerId;
begin
  try
    try
      err.Code := ERR_NO_ERROR;
      err.line := 0;

      if not FileExists(fName) then
        err.Code := ERR_FILE_EXISTS;

      if err.Code = ERR_NO_ERROR then
        AssignFile(fileHandle, fName);

      if err.Code = ERR_NO_ERROR then
      begin
{$I-}
        reset(fileHandle);
        err.Code := IOResult;
{$I+}
      end;

      if err.Code = ERR_NO_ERROR then
      begin
        inc(err.line);
        err.Code := readNumberOfPlayers(fileHandle, gameStructure.numberOfPlayers);
      end;

      if err.Code = ERR_NO_ERROR then
      begin
        inc(err.line);
        err.Code := readCurrentPlayer(fileHandle, gameStructure.currentPlayerId, gameStructure.numberOfPlayers);
      end;

      if err.Code = ERR_NO_ERROR then
        for id := 0 to gameStructure.numberOfPlayers - 1 do
        begin
          inc(err.line);
          err.Code := readPlayer(fileHandle, gameStructure.playerStats[id]);
        end;

      if err.Code = ERR_NO_ERROR then
      begin
        inc(err.line);
        err.Code := readCardStack(fileHandle, gameStructure.cardStack);
      end;

      if err.Code = ERR_NO_ERROR then
        err.line := 0;
    except

    end;

  finally
    close(fileHandle);
    loadFromFile := err;
  end;
end;

end.
