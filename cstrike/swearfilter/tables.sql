-- ------------------------------------------------------------------------------------
--  Table Creation                                                                   --
-- ------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `SF_BlackList` (
`Word` VARCHAR(24) NOT NULL DEFAULT '' PRIMARY KEY
) TYPE = MYISAM COMMENT = 'AMX SwearFilter BlackList';

CREATE TABLE IF NOT EXISTS `SF_WhiteList` (
`Word` VARCHAR(24) NOT NULL DEFAULT '' PRIMARY KEY
) TYPE = MYISAM COMMENT = 'AMX SwearFilter WhiteList';

CREATE TABLE IF NOT EXISTS `SF_Punishment` (
`Offense` INT UNSIGNED DEFAULT '0' NOT NULL PRIMARY KEY,
`Punish` VARCHAR(7) NOT NULL DEFAULT 'a'
) TYPE = MYISAM COMMENT = 'AMX SwearFilter Punishments';


-- ------------------------------------------------------------------------------------
--  Data Insertion                                                                   --
-- ------------------------------------------------------------------------------------

-- BlackList Words
Insert Into SF_BlackList (Word) Values ('shit');
Insert Into SF_BlackList (Word) Values ('pussy');
Insert Into SF_BlackList (Word) Values ('nigger');
Insert Into SF_BlackList (Word) Values ('fag');
Insert Into SF_BlackList (Word) Values ('bitch');
Insert Into SF_BlackList (Word) Values ('asshole');
Insert Into SF_BlackList (Word) Values ('cunt');
Insert Into SF_BlackList (Word) Values ('clit');
Insert Into SF_BlackList (Word) Values ('pussies');
Insert Into SF_BlackList (Word) Values ('pussy');
Insert Into SF_BlackList (Word) Values ('nigga');
Insert Into SF_BlackList (Word) Values ('fuck');
Insert Into SF_BlackList (Word) Values ('foad');
Insert Into SF_BlackList (Word) Values ('homo');
Insert Into SF_BlackList (Word) Values ('lesbian');
Insert Into SF_BlackList (Word) Values ('gay');
Insert Into SF_BlackList (Word) Values ('cock');
Insert Into SF_BlackList (Word) Values ('dick');
Insert Into SF_BlackList (Word) Values ('douche');
Insert Into SF_BlackList (Word) Values ('whore');
Insert Into SF_BlackList (Word) Values ('hooker');
Insert Into SF_BlackList (Word) Values ('bastard');
Insert Into SF_BlackList (Word) Values ('biatch');
Insert Into SF_BlackList (Word) Values ('damn');
Insert Into SF_BlackList (Word) Values ('goddamn');
Insert Into SF_BlackList (Word) Values ('goddammit');
Insert Into SF_BlackList (Word) Values ('goddamnit');


-- WhiteList Words
Insert Into SF_WhiteList (Word) Values ('fun');
Insert Into SF_WhiteList (Word) Values ('who');
Insert Into SF_WhiteList (Word) Values ('what');
Insert Into SF_WhiteList (Word) Values ('when');
Insert Into SF_WhiteList (Word) Values ('where');
Insert Into SF_WhiteList (Word) Values ('which');
Insert Into SF_WhiteList (Word) Values ('why');
Insert Into SF_WhiteList (Word) Values ('whew');
Insert Into SF_WhiteList (Word) Values ('assault');
Insert Into SF_WhiteList (Word) Values ('assassin');


-- Progressive Punishment System (Offense Count Order)
-- Note: You may add more or less, depending on how many offenses you allow!
Insert Into SF_Punishment (Offense, Punish) Values (1, 'a');    -- First Offense (Gag)
Insert Into SF_Punishment (Offense, Punish) Values (2, 'ab');   -- Second Offense (Gag, Slap)
Insert Into SF_Punishment (Offense, Punish) Values (3, 'ac');   -- Third Offense (Gag, Fire)
Insert Into SF_Punishment (Offense, Punish) Values (4, 'ade');  -- Fourth Offense (Gag, Slay, Cash-Loss)
Insert Into SF_Punishment (Offense, Punish) Values (5, 'f');    -- Fifth Offense (Kick)

