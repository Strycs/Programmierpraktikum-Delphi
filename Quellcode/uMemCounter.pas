{
	<summary>

	</summary>
	<author>Morten Schobert</author>
	<created>18.03.2025</created>
	<version>1.0</version>
	<remarks></remarks>
}
{ ------------------------------------------------------------------------------
	Dieses Modul übernimmt die Verwaltung von Objektinstanzen durch das Zählen
	ihrer Erzeugung und Freigabe. Es stellt Funktionen zur Verfügung, um den
	Instanzzähler gezielt zu erhöhen oder zu verringern, sowie um Komponenten und
	Objekte kontrolliert zu erstellen und freizugeben. Damit wird sichergestellt,
	dass Ressourcen effizient genutzt und Speicherlecks vermieden werden.

	Autoren: Morten Schobert, 12.03.2025
	------------------------------------------------------------------------------ }
unit uMemCounter;

interface

uses
	system.classes;

/// <summary>
/// Gibt die Instanz des Objekts frei, indem der Instanzzähler dekrementiert und das Objekt freigegeben wird.
/// </summary>
/// <param name="obj">Das Objekt, das freigegeben werden soll.</param>
procedure releaseInstance(const obj: TObject);overload;

/// <summary>
/// Gibt die Instanz des pointers frei, indem der Instanzzähler dekrementiert und der pointer freigegeben wird.
/// </summary>
/// <remarks>
/// falls der Pointer auf eine Datenstruktur zeigt, die von Delphi gemanagete dynamiische Datentypen verwendet,
///  dann muss in der aufrufenden Methode ein finalize aufgerufen werden
/// </remarks>
/// <param name="ptr">Der Pointer, das freigegeben werden soll.</param>
procedure releaseInstance(const ptr: pointer); overload;

/// <summary>
/// Erstellt eine Komponente der angegebenen Klasse, inkrementiert den Instanzzähler und gibt die Komponente zurück.
/// </summary>
/// <param name="classId">Die Klassenreferenz der zu erstellenden Komponente.</param>
/// <returns>Die erstellte Komponente.</returns>
function createComponent(classId: TComponentClass): TComponent;

/// <summary>
/// Erstellt ein Objekt der angegebenen Klasse, inkrementiert den Instanzzähler und gibt das Objekt zurück.
/// </summary>
/// <param name="classId">Die Klassenreferenz des zu erstellenden Objekts.</param>
/// <returns>Das erstellte Objekt.</returns>
function createObject(classId: TClass): TObject;

/// <summary>
/// Erstellt  dynamisch memory  inkrementiert den Instanzzähler
/// </summary>
/// <param name="size">die größe des memory</param>
/// <returns>einen pointer auf das erzeuge Memory</returns>
/// <remarks>
/// falls Memory für eine Datenstruktur erzeugt wird, die von Delphi gemanagete dynamiische Datentypen verwendet,
///  dann muss in der aufrufenden Methode ein inititialize aufgerufen werden
/// </remarks>
function createMemory(size:cardinal): Pointer;
implementation

uses
	vcl.Dialogs, sysutils;

type
	/// <summary>
	/// Datensatz zur Speicherung der Klassenreferenz und der Anzahl der Instanzen.
	/// </summary>
	TInstanceRec = record
		classId: TClass;
		count: UInt64;
	end;

	TInstances = array of TInstanceRec;
	PInstances = ^TInstanceRec;

var
	numOfclasses: integer;
	instances: PInstances;

  /// <summary>
/// Sucht im internen Speicher nach einem Slot, der der angegebenen Klassenreferenz entspricht.
/// </summary>
/// <param name="classId">Die Klassenreferenz, nach der gesucht wird.</param>
/// <returns>Den Index des Slots oder -1, falls kein passender Slot gefunden wurde.</returns>
function findSlot(classId: TClass): integer;
var
	ptrSlot: PInstances;
begin
	findSlot := -1;
	ptrSlot := instances;
	for var Id := 0 to numOfclasses - 1 do
	begin
		if ptrSlot^.classId = classId then
			findSlot := Id;
		inc(ptrSlot);
	end;
end;

/// <summary>
/// Fügt einen neuen Slot für die angegebene Klassenreferenz hinzu und initialisiert den Instanzzähler auf 0.
/// </summary>
/// <param name="classId">Die Klassenreferenz, für die ein Slot hinzugefügt wird.</param>
procedure addSlot(classId: TClass);
var
	ptrSlot: PInstances;
begin
	if numOfclasses = 0 then
		// GetMem(instances, sizeof(TInstanceRec))
			instances := AllocMem(SizeOf(TInstanceRec))
	else
		ReallocMem(instances, (numOfclasses + 1) * SizeOf(TInstanceRec));

	ptrSlot := instances;

	inc(numOfclasses);

	inc(ptrSlot, numOfclasses - 1);

	ptrSlot^.classId := classId;
	ptrSlot^.count := 0;
end;

procedure incInstance(obj: TObject);
var
	Id: integer;
	classId: TClass;
	ptrSlot: PInstances;
begin
	ptrSlot := instances;

	classId := nil;
	if obj <> nil then
		classId := obj.ClassType;

	Id := findSlot(classId);
	if Id = -1 then
	begin
		addSlot(classId);
		ptrSlot := instances;
		inc(ptrSlot, numOfclasses - 1);
		inc(ptrSlot^.count);
	end
	else
	begin
		ptrSlot := instances;
		inc(ptrSlot, Id);
		inc(ptrSlot^.count);
	end;
end;

procedure decInstance(obj: TObject);
var
	Id: integer;
	classId: TClass;
	className: string;
	ptrSlot: PInstances;
begin
	classId := nil;
	if obj <> nil then
		classId := obj.ClassType;

	if classId = nil then
		className := 'others'
	else
		className := classId.className;

	Id := findSlot(classId);

	if Id = -1 then
		ShowMessage('class: ' + className + ' never instantiated but shall be released');

	ptrSlot := instances;
	inc(ptrSlot, Id);

	if ptrSlot^.count <= 0 then
		ShowMessage('class: ' + className + ' Instances have all been freed already')
	else
		dec(ptrSlot^.count);
end;

function createObject(classId: TClass): TObject;
var
	obj: TObject;
begin
	obj := classId.create;
	incInstance(obj);
	createObject := obj;
end;

function createComponent(classId: TComponentClass): TComponent;
var
	obj: TComponent;
begin
	obj := classId.create(nil);
	incInstance(obj);
	createComponent := obj;
end;

function createMemory(size:cardinal): Pointer;
begin
	incInstance(nil);
	createMemory := getMemory(size);;
end;
procedure releaseInstance(const ptr: pointer); overload;
begin
	decInstance(nil);
	FreeMem(ptr);
end;

procedure releaseInstance(const obj: TObject);
begin
	decInstance(obj);
	FreeAndNil(obj);
end;

/// <summary>
/// Überprüft, ob noch Instanzen nicht freigegeben wurden, und zeigt eine Meldung an, falls dies der Fall ist.
/// </summary>
procedure isAllMemoryFreed;
var
	className: string;
	ptrSlot: PInstances;
begin
	ptrSlot := instances;
	for var Id := 0 to numOfclasses - 1 do
	begin
		with ptrSlot^ do
		begin
			if count > 0 then
			begin
				if classId = nil then
					className := 'others'
				else
					className := classId.className;
				ShowMessage('of the class: ' + className + ' are still ' + intToStr(ptrSlot^.count) + ' instances  allocated');
			end;
			inc(ptrSlot);
		end;
	end;
end;

initialization

instances := nil;
numOfclasses := 0;

finalization

isAllMemoryFreed;
freemem(instances);

end.
