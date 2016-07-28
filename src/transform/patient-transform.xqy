xquery version "1.0-ml";
module namespace trns = "http://marklogic.com/transform/patient";

import module namespace codes = "http://marklogic.com/ns/codes" at "/lib/codes.xqy";

import module namespace sem = "http://marklogic.com/semantics"
  at "/MarkLogic/semantics.xqy";

declare namespace cms = "http://marklogic.com/cms";
declare namespace hl7 = "urn:hl7-org:v3";
declare namespace zip-geo = "geonames.org/zip-geo";

declare variable $FIRST-NAMES := ('Abbot', 'Abdul', 'Abel', 'Abigail', 'Abra', 'Abraham', 'Acton', 'Adam', 'Adara', 'Addison', 'Adele', 'Adèle', 'Adena', 'Adria', 'Adrian', 'Adrienne', 'Agathe', 'Ahmed', 'Aidan', 'Aiko', 'Aileen', 'Aimee', 'Ainsley', 'Akeem', 'Aladdin', 'Alain', 'Alan', 'Alana', 'Albert', 'Alden', 'Aldine', 'Alea', 'Alec', 'Alexa', 'Alexander', 'Alexandra', 'Alexis', 'Alfonso', 'Alfred', 'Alfreda', 'Ali', 'Alice', 'Alika', 'Aline', 'Alisa', 'Alix', 'Allegra', 'Allen', 'Allisone', 'Allistair', 'Alma', 'Althea', 'Alvin', 'Alyssa', 'Amal', 'Amanda', 'Amaya', 'Amber', 'Amela', 'Amelia', 'Amena', 'Amery', 'Amethyst', 'Amir', 'Amity', 'Amos', 'Amy', 'Anastasia', 'Anastasie', 'André', 'Andrew', 'Anea', 'Angela', 'Angelica', 'Anika', 'Anjolie', 'Ann', 'Anne', 'Annelle', 'Anthony', 'Anton', 'Aphrodite', 'April', 'Aquila', 'Arden', 'Aretha', 'Ariana', 'Ariel', 'Aristotle', 'Armand', 'Armando', 'Arnaude', 'Arsenio', 'Arthur', 'Ashely', 'Asher', 'Ashton', 'Aspen', 'Astra', 'Athena', 'Aubrey', 'Audra', 'Audrey', 'August', 'Aurelia', 'Aurélie', 'Aurora', 'Aurore', 'Austin', 'Autumn', 'Ava', 'Avye', 'Axel', 'Ayanna', 'Azalia', 'Baker', 'Barbara', 'Barclay', 'Barrett', 'Barry', 'Basia', 'Basil', 'Baxter', 'Beatrice', 'Beau', 'Bell', 'Belle', 'Benedict', 'Benjamin', 'Berk', 'Bernadette', 'Bernard', 'Berouria', 'Bert', 'Bertha', 'Bertilde', 'Bertrand', 'Bethany', 'Beverly', 'Bevis', 'Bianca', 'Blaine', 'Blair', 'Blake', 'Blaze', 'Blossom', 'Blythe', 'Bo', 'Boris', 'Bradley', 'Brady', 'Branden', 'Brandon', 'Bree', 'Brenda', 'Brendan', 'Brenden', 'Brenna', 'Brennan', 'Brent', 'Brett', 'Brian', 'Brianna', 'Briar', 'Brielle', 'Britanney', 'Brittany', 'Brock', 'Brody', 'Brooke', 'Bruce', 'Bruno', 'Bryar', 'Brynne', 'Buckminster', 'Buffy', 'Burke', 'Burton', 'Byron', 'Cade', 'Cadman', 'Caesar', 'Cailin', 'Cain', 'Cairo', 'Caldwell', 'Caleb', 'Calista', 'Callie', 'Callum', 'Cally', 'Calvin', 'Camden', 'Cameran', 'Cameron', 'Camilla', 'Camille', 'Candace', 'Candice', 'Cara', 'Carissa', 'Carl', 'Carla', 'Carlos', 'Carly', 'Carol', 'Carolyn', 'Carson', 'Carter', 'Caryn', 'Casey', 'Cassady', 'Cassandra', 'Cassandre', 'Cassidy', 'Castor', 'Catherine', 'Cathiana', 'Cathleen', 'Cecilia', 'Cedric', 'Chadwick', 'Chaim', 'Chancellor', 'Chanda', 'Chandler', 'Chaney', 'Channing', 'Chantale', 'Charde', 'Charissa', 'Charity', 'Charles', 'Charlotte', 'Chase', 'Chastity', 'Chava', 'Chelsea', 'Cherokee', 'Cheryl', 'Chester', 'Cheyenne', 'Chima', 'Chiquita', 'Chloe', 'Christelle', 'Christen', 'Christian', 'Christine', 'Christophe', 'Christopher', 'Ciara', 'Ciaran', 'Claire', 'Clare', 'Clark', 'Clarke', 'Claude', 'Claudia', 'Claudine', 'Clayton', 'Clémence', 'Clementine', 'Cleo', 'Clinton', 'Clio', 'Coby', 'Cody', 'Colby', 'Cole', 'Colette', 'Colin', 'Colorado', 'Colt', 'Colton', 'Conan', 'Connor', 'Constance', 'Cooper', 'Cora', 'Cordélie', 'Courtney', 'Craig', 'Cruz', 'Cullen', 'Curran', 'Cynthia', 'Cyrienne', 'Cyrus', 'Dahlia', 'Dai', 'Dakota', 'Dale', 'Dalton', 'Damian', 'Damon', 'Dana', 'Dane', 'Daniel', 'Danielle', 'Dante', 'Daphne', 'Daquan', 'Dara', 'Daria', 'Darius', 'Darrel', 'Darryl', 'Daryl', 'David', 'Davis', 'Dawn', 'Deacon', 'Dean', 'Deanna', 'Deborah', 'Declan', 'Deirdre', 'Delilah', 'Delima', 'Demetria', 'Demetrius', 'Denis', 'Denise', 'Dennis', 'Denton', 'Derek', 'Desirae', 'Desiree', 'Destiny', 'Devin', 'Dexter', 'Diane', 'Diereba', 'Dieter', 'Dillon', 'Dolan', 'Dominic', 'Dominique', 'Donna', 'Donovan', 'Dora', 'Dorian', 'Doris', 'Dorothy', 'Drake', 'Drew', 'Driscoll', 'Dulcinée', 'Duncan', 'Dustin', 'Dylan', 'Eagan', 'Eaton', 'Ebony', 'Echo', 'Edan', 'Eden', 'Edward', 'Elaine', 'Eleanor', 'Éléonore', 'Eliana', 'Elijah', 'Elizabeth', 'Ella', 'Elliott', 'Elmo', 'Elton', 'Elvis', 'Emerald', 'Emerson', 'Emery', 'Emi', 'Emily', 'Emma', 'Emmanuel', 'Emmanuelle', 'Erasmus', 'Eric', 'Éric', 'Erica', 'Erich', 'Erin', 'Esperie', 'Ethan', 'Étiennette', 'Eugenia', 'Euphrosine', 'Evan', 'Evangeline', 'Eve', 'Evelyn', 'Ezekiel', 'Ezra', 'Fabian', 'Fabien', 'Faith', 'Fallon', 'Farrah', 'Fatima', 'Fay', 'Felicia', 'Felix', 'Felixiane', 'Ferdinand', 'Ferris', 'Finn', 'Fiona', 'Fitzgerald', 'Flavia', 'Fletcher', 'Fleur', 'Flore', 'Florence', 'Florent', 'Florian', 'Florida', 'Flynn', 'Forrest', 'Frances', 'Francesca', 'Francis', 'Franck', 'François', 'Françoise', 'Frédéric', 'Fredericka', 'Frederika', 'Frédérique', 'Freya', 'Fridoline', 'Fritz', 'Fuller', 'Gabriel', 'Gage', 'Gail', 'Galena', 'Galvin', 'Gania', 'Gannon', 'Gareth', 'Garrett', 'Garrison', 'Garth', 'Gary', 'Gascalon', 'Gasper', 'Gauthier', 'Gaven', 'Gavin', 'Gay', 'Gemma', 'Genevieve', 'Geneviève', 'Geoffrey', 'George', 'Georges', 'Georgia', 'Géorgie', 'Gérard', 'Germaine', 'Germane', 'Giacomo', 'Gil', 'Gilbert', 'Giles', 'Gillian', 'Ginger', 'Girald', 'Gisela', 'Giselle', 'Glenna', 'Gloria', 'Grace', 'Grady', 'Graham', 'Graiden', 'Grant', 'Gray', 'Grégoire', 'Gregory', 'Gretchen', 'Griffin', 'Griffith', 'Guillemette', 'Guinevere', 'Gustave', 'Guy', 'Gwendolyn', 'Hadassah', 'Hadley', 'Hakeem', 'Haley', 'Hall', 'Halla', 'Hamilton', 'Hamish', 'Hammett', 'Hanae', 'Hanna', 'Hannah', 'Harding', 'Harlan', 'Harper', 'Harriet', 'Harrison', 'Hasad', 'Hashim', 'Haviva', 'Hayden', 'Hayes', 'Hayfa', 'Hayley', 'Heather', 'Hector', 'Hedda', 'Hedley', 'Hedwig', 'Hedy', 'Heidi', 'Helen', 'Henri', 'Henry', 'Herman', 'Hermione', 'Herrod', 'Hilary', 'Hilda', 'Hilel', 'Hillary', 'Hiram', 'Hiroko', 'Hollee', 'Holly', 'Holmes', 'Honorato', 'Honoré', 'Hop', 'Hope', 'Howard', 'Hoyt', 'Hu', 'Hugues', 'Hunter', 'Hyacinth', 'Hyatt', 'Idola', 'Idona', 'Ifeoma', 'Ignacia', 'Ignatius', 'Igor', 'Ila', 'Iliana', 'Illana', 'Illiana', 'Ima', 'Imani', 'Imelda', 'Imogene', 'Ina', 'India', 'Indigo', 'Indira', 'Inez', 'Inga', 'Ingrid', 'Iola', 'Iona', 'Ira', 'Irene', 'Iris', 'Irma', 'Isaac', 'Isabella', 'Isabelle', 'Isadora', 'Isaiah', 'Ishmael', 'Ivan', 'Ivana', 'Ivor', 'Ivory', 'Ivy', 'Jack', 'Jackson', 'Jacob', 'Jacqueline', 'Jacques', 'Jacquot', 'Jada', 'Jade', 'Jaden', 'Jael', 'Jaime', 'Jakeem', 'Jamal', 'James', 'Jameson', 'Jana', 'Jane', 'Janna', 'Jaquelyn', 'Jared', 'Jarrod', 'Jasmine', 'Jason', 'Jasper', 'Jayme', 'Jean', 'Jean-Cyril', 'Jean-Jacques', 'Jean-Luc', 'Jean-Marc', 'Jean-Pascal', 'Jean-Roch', 'Jean-Yves', 'Jeanette', 'Jeanne', 'Jeannise', 'Jeannotte', 'Jelani', 'Jémil', 'Jemima', 'Jena', 'Jenette', 'Jennifer', 'Jeremy', 'Jermaine', 'Jerome', 'Jérôme', 'Jéromin', 'Jéronim', 'Jerry', 'Jescie', 'Jessamine', 'Jesse', 'Jessica', 'Jillian', 'Jin', 'Joan', 'Jocelyn', 'Joel', 'John', 'Jolene', 'Jolie', 'Jonah', 'Jonas', 'Jonathan', 'Jordan', 'Jorden', 'Joseph', 'Josephe', 'Josephine', 'Joséphine', 'Josette', 'Joshua', 'Josiah', 'Joy', 'Judah', 'Judith', 'Jules', 'Julian', 'Julie', 'Juliet', 'Justin', 'Justina', 'Justine', 'Kadeem', 'Kaden', 'Kai', 'Kaitlin', 'Kalia', 'Kamal', 'Kameko', 'Kane', 'Kareem', 'Karen', 'Karina', 'Karleigh', 'Karly', 'Karyn', 'Kaseem', 'Kasimir', 'Kasper', 'Katell', 'Katelyn', 'Kathleen', 'Kato', 'Kay', 'Kaye', 'Keane', 'Keaton', 'Keefe', 'Keegan', 'Keelie', 'Keely', 'Keiko', 'Keith', 'Kellie', 'Kelly', 'Kelsey', 'Kelsie', 'Kendall', 'Kennan', 'Kennedy', 'Kenneth', 'Kenyon', 'Kermit', 'Kerry', 'Kessie', 'Kevin', 'Kevyn', 'Kiara', 'Kiayada', 'Kibo', 'Kieran', 'Kim', 'Kimberley', 'Kimberly', 'Kiona', 'Kirby', 'Kirestin', 'Kirk', 'Kirsten', 'Kitra', 'Knox', 'Kristen', 'Kuame', 'Kyla', 'Kylan', 'Kyle', 'Kylee', 'Kylie', 'Kylynn', 'Kyra', 'Lacey', 'Lacota', 'Lacy', 'Lael', 'Laetitia', 'Laith', 'Lamar', 'Lambert', 'Lana', 'Lance', 'Lane', 'Lani', 'Lara', 'Lareina', 'Larissa', 'Lars', 'Latifah', 'Laura', 'Laurel', 'Lavinia', 'Lawrence', 'Leah', 'Leandra', 'Lee', 'Leigh', 'Leila', 'Leilani', 'Len', 'Lenore', 'Leo', 'Leonard', 'Leroy', 'Lesley', 'Leslie', 'Lester', 'Lev', 'Levi', 'Lewis', 'Libby', 'Liberty', 'Lila', 'Lilah', 'Lillith', 'Lilou', 'Linda', 'Linus', 'Lionel', 'Lisandra', 'Livina', 'Logan', 'Lois', 'Louis', 'Louise', 'Lucas', 'Lucian', 'Lucie', 'Lucius', 'Lucy', 'Luke', 'Lunea', 'Lydia', 'Lyle', 'Lynn', 'Lysandra', 'Maamar', 'Macaulay', 'Macey', 'MacKensie', 'MacKenzie', 'Macon', 'Macy', 'Madaline', 'Madeline', 'Madeson', 'Madih', 'Madison', 'Madoc', 'Madonna', 'Magee', 'Maggie', 'Maggy', 'Maia', 'Maile', 'Maisie', 'Maite', 'Malachi', 'Malcolm', 'Malik', 'Mallory', 'Mannix', 'Mara', 'Marah', 'Marc', 'Marcel', 'Marcia', 'Marck', 'Margaret', 'Mari', 'Mariam', 'Marie-Lydie', 'Mariko', 'Maris', 'Mark', 'Marny', 'Marsden', 'Marshall', 'Martena', 'Martha', 'Marthe', 'Martin', 'Martina', 'Marvin', 'Mary', 'Maryam', 'Marybel', 'Mason', 'Mathilde', 'Mathis', 'Matthew', 'Matthieu', 'Mattia', 'Mattiassu', 'Max', 'Maxance', 'Maxime', 'Maxine', 'Maxwell', 'May', 'Maya', 'McKenzie', 'Mechelle', 'Medge', 'Megan', 'Meghan', 'Melanie', 'Melinda', 'Melissa', 'Melodie', 'Melvin', 'Melyssa', 'Mercedes', 'Meredith', 'Merrill', 'Merritt', 'Mia', 'Micah', 'Michael', 'Michelle', 'Mikayla', 'Minerva', 'Minerve', 'Miranda', 'Miriam', 'Moana', 'Mohamed', 'Mohammad', 'Mohammed', 'Mohhamud', 'Mollie', 'Molly', 'Mona', 'Montana', 'Morgan', 'Moses', 'Mufutau', 'Murphy', 'Myles', 'Myra', 'Nadine', 'Naida', 'Naomi', 'Nash', 'Nasia', 'Nasim', 'Natale', 'Natalie', 'Nataniel', 'Nathalye', 'Nathan', 'Nathaniel', 'Nayda', 'Nehru', 'Neil', 'Nell', 'Nelle', 'Nerea', 'Nero', 'Nevada', 'Neve', 'Neville', 'Nicholas', 'Nichole', 'Nicky', 'Nicolas', 'Nicole', 'Nigel', 'Nina', 'Nissim', 'Nita', 'Noah', 'Noble', 'Noel', 'Noelani', 'Noelle', 'Noémi', 'Nola', 'Nolan', 'Nomlanga', 'Nora', 'Norman', 'Nyssa', 'Ocean', 'Octavia', 'Octavius', 'Odessa', 'Odette', 'Odysseus', 'Oleg', 'Olga', 'Oliver', 'Olivia', 'Olympe', 'Olympia', 'Olympie', 'Omar', 'Ophélie', 'Oprah', 'Ora', 'Orbert', 'Oren', 'Ori', 'Orla', 'Orlando', 'Orli', 'Orson', 'Oscar', 'Otto', 'Owen', 'Paki', 'Palmer', 'Paloma', 'Pamela', 'Pandora', 'Pascale', 'Patience', 'Patricia', 'Patrick', 'Paul', 'Paul-Adrien', 'Paul-Henri', 'Paula', 'Paulette', 'Pearl', 'Pélagie', 'Penelope', 'Pénélope', 'Perette', 'Perry', 'Peter', 'Petra', 'Pétronille', 'Phébe', 'Phelan', 'Philip', 'Philippine', 'Phillip', 'Phoebe', 'Phyllis', 'Pierre', 'Pierre-Jean', 'Pierre-Loup', 'Pierre-Marie', 'Piper', 'Plato', 'Porter', 'Portia', 'Prescott', 'Preston', 'Price', 'Priscilla', 'Priscille', 'Quail', 'Quamar', 'Quemby', 'Quentin', 'Quin', 'Quincy', 'Quinlan', 'Quinn', 'Quintessa', 'Quon', 'Quyn', 'Quynn', 'Rachel', 'Rae', 'Rafael', 'Rahim', 'Raja', 'Rajah', 'Ralph', 'Rama', 'Ramona', 'Rana', 'Randall', 'Raphael', 'Rashad', 'Raven', 'Ray', 'Raya', 'Raymond', 'Reagan', 'Rebecca', 'Rebekah', 'Reece', 'Reed', 'Reese', 'Regan', 'Regina', 'Remedios', 'Rémi', 'Renee', 'Renée', 'Reuben', 'Rhea', 'Rhiannon', 'Rhoda', 'Rhona', 'Rhonda', 'Ria', 'Richard', 'Rigel', 'Riley', 'Rina', 'Rinah', 'Risa', 'Roanna', 'Roary', 'Robert', 'Roberte', 'Robin', 'Robine', 'Rogan', 'Roger', 'Rolan', 'Ronan', 'Rooney', 'Rosa', 'Rosalyn', 'Rose', 'Ross', 'Roth', 'Rowan', 'Ruby', 'Rudyard', 'Russell', 'Ruth', 'Ryan', 'Ryder', 'Rylee', 'Sacha', 'Sade', 'Sage', 'Salvador', 'Samantha', 'Samson', 'Samuel', 'Sandra', 'Sapha', 'Sara', 'Sarah', 'Sasha', 'Savannah', 'Sawyer', 'Scarlet', 'Scarlett', 'Scott', 'Sean', 'Sebastian', 'Selma', 'September', 'Séraphie', 'Séraphine', 'Serena', 'Serina', 'Seth', 'Shad', 'Shaeleigh', 'Shafira', 'Shaine', 'Shana', 'Shannon', 'Shay', 'Shea', 'Sheila', 'Shelby', 'Shelley', 'Shellie', 'Shelly', 'Shoshana', 'Sierra', 'Signe', 'Sigourney', 'Silas', 'Simon', 'Simone', 'Skyler', 'Slade', 'Sloane', 'Sohila', 'Solomon', 'Sonia', 'Sonya', 'Sophia', 'Sophie', 'Sopoline', 'Stacey', 'Stacy', 'Steel', 'Stella', 'Stephanie', 'Stephen', 'Steven', 'Stewart', 'Stone', 'Stuart', 'Suki', 'Summer', 'Susan', 'Susanne', 'Suzanne', 'Sybil', 'Sybill', 'Sydnee', 'Sydney', 'Sylvester', 'Sylvia', 'Sylvie', 'Tad', 'Tallulah', 'Talon', 'Tamara', 'Tamekah', 'Tana', 'Tanek', 'Tanisha', 'Tanner', 'Tanya', 'Tara', 'Tarik', 'Tasha', 'Tashya', 'TaShya', 'Tate', 'Tatiana', 'Tatum', 'Tatyana', 'Taylor', 'Teagan', 'Teegan', 'Terence', 'Terrence', 'Thaddeus', 'Thane', 'Theodore', 'Théodore', 'Théophile', 'Thérèse', 'Thibault', 'Thierry', 'Thomas', 'Thor', 'Tiger', 'Timmy', 'Timon', 'Timoté', 'Timotée', 'Timothy', 'Titus', 'Tobias', 'Tobin', 'Todd', 'Travis', 'Trevor', 'Troy', 'Tucker', 'Tyler', 'Tyrone', 'Ulla', 'Ulric', 'Ulysses', 'Uma', 'Unity', 'Upton', 'Uriah', 'Uriel', 'Urielle', 'Ursa', 'Ursula', 'Uta', 'Valentine', 'Vance', 'Vanna', 'Vaughan', 'Veda', 'Velma', 'Venus', 'Vera', 'Vernon', 'Veronica', 'Victor', 'Victoria', 'Vincent', 'Violet', 'Virginia', 'Vivian', 'Vivien', 'Vivienne', 'Vladimir', 'Wade', 'Walker', 'Wallace', 'Walter', 'Wanda', 'Wang', 'Warren', 'Wayne', 'Wesley', 'Whilemina', 'Whitney', 'Whoopi', 'Willa', 'William', 'Willow', 'Wilma', 'Wing', 'Winifred', 'Winter', 'Wyatt', 'Wylie', 'Wynne', 'Wynter', 'Wyoming', 'Xainte', 'Xander', 'Xandra', 'Xantha', 'Xanthus', 'Xavier', 'Xaviera', 'Xena', 'Xenos', 'Xerxes', 'Xyla', 'Yael', 'Yani', 'Yanick', 'Yardley', 'Yasir', 'Yen', 'Yeo', 'Yetta', 'Yolanda', 'Yoshi', 'Yoshio', 'Yuli', 'Yuri', 'Yves', 'Yvette', 'Yvonne', 'Zacharie', 'Zachary', 'Zachery', 'Zahir', 'Zane', 'Zelda', 'Zelenia', 'Zelida', 'Zena', 'Zenaida', 'Zenia', 'Zeph', 'Zephania', 'Zephr', 'Zeus', 'Zia', 'Zoe', 'Zoé', 'Zorita');
declare variable $FIRST-NAMES-COUNT := fn:count($FIRST-NAMES);

declare variable $MALE-FIRST-NAMES := ('Abbot','Abdul','Abel','Abraham','Acton','Adam','Addison','Adrian','Ahmed','Aidan','Akeem','Alan','Albert','Alec','Alfonso','Ali','Allen','Allistair','Alvin','Amal','Amir','Andrew','Anthony','Aquila','Arden','Aristotle','Armand','Armando','Arsenio','Arthur','Asher','Ashton','Aubrey','Austin','Axel','Barclay','Barrett','Barry','Basil','Beau','Benjamin','Berk','Bernard','Bert','Bevis','Blaine','Blair','Blake','Blaze','Boris','Bradley','Brady','Brandon','Brendan','Brenden','Brennan','Brent','Brett','Brian','Brock','Brody','Bruce','Bruno','Burke','Burton','Byron','Cade','Caesar','Cairo','Caldwell','Caleb','Callum','Calvin','Camden','Cameron','Carl','Carlos','Carson','Carter','Castor','Cedric','Chadwick','Chaim','Chancellor','Chandler','Charles','Chester','Ciaran','Clark','Clarke','Clayton','Clinton','Colby','Colin','Colorado','Colt','Colton','Conan','Connor','Cooper','Craig','Cruz','Curran','Cyrus','Dakota','Dale','Dalton','Damian','Damon','Dane','Daniel','Dante','David','Davis','Deacon','Dean','Declan','Dennis','Denton','Derek','Dieter','Dillon','Dolan','Dominic','Dorian','Drew','Driscoll','Duncan','Dustin','Dylan','Eagan','Eaton','Edan','Edward','Elmo','Elton','Emerson','Emery','Emmanuel','Erasmus','Eric','Erich','Ethan','Evan','Ezekiel','Ezra','Felix','Ferdinand','Ferris','Finn','Fitzgerald','Fletcher','Flynn','Forrest','Francis','Fritz','Fuller','Gabriel','Gage','Gannon','Gareth','Garrett','Garrison','Garth','Gary','Gavin','Geoffrey','George','Giacomo','Gil','Grady','Graham','Graiden','Gray','Gregory','Hall','Hamilton','Hammett','Harding','Harlan','Harrison','Hasad','Hayden','Hayes','Hector','Hedley','Henry','Herrod','Hilel','Hiram','Holmes','Honorato','Hop','Howard','Hoyt','Hu','Hunter','Hyatt','Ignatius','Igor','Isaac','Isaiah','Ishmael','Ivan','Jack','Jackson','Jacob','Jakeem','Jamal','James','Jameson','Jared','Jarrod','Jason','Jasper','Jelani','Jerome','Jesse','Jin','Joel','John','Jonah','Jonas','Jonathan','Jordan','Joseph','Joshua','Josiah','Judah','Julian','Justin','Kadeem','Kaden','Kamal','Kane','Kaseem','Kasimir','Kasper','Kato','Keane','Keefe','Keegan','Keith','Kelly','Kendall','Kenneth','Kenyon','Kermit','Kevin','Kibo','Kieran','Kirk','Knox','Kuame','Kyle','Laith','Lamar','Lance','Lane','Lars','Lee','Len','Leo','Leonard','Leroy','Lester','Lev','Levi','Lewis','Linus','Lionel','Logan','Louis','Lucas','Lucius','Luke','Lyle','Macaulay','Macon','Magee','Malachi','Malcolm','Mannix','Mark','Marsden','Marshall','Martin','Marvin','Mason','Matthew','Maxwell','Melvin','Merrill','Merritt','Michael','Mohammad','Moses','Mufutau','Murphy','Myles','Nash','Nathan','Nathaniel','Nehru','Neil','Nero','Neville','Nicholas','Nicolas','Nigel','Nissim','Noah','Noble','Nolan','Norman','Odysseus','Oliver','Omar','Orlando','Orson','Oscar','Otto','Owen','Paki','Palmer','Patrick','Paul','Perry','Peter','Phelan','Philip','Phillip','Plato','Porter','Prescott','Preston','Price','Quamar','Quentin','Quincy','Quinlan','Quinn','Rafael','Rahim','Raja','Rajah','Ralph','Randall','Raphael','Rashad','Ray','Raymond','Reece','Reed','Reese','Richard','Robert','Rogan','Ronan','Rooney','Ross','Roth','Russell','Salvador','Samson','Samuel','Sawyer','Scott','Sean','Sebastian','Seth','Shad','Silas','Simon','Slade','Sloane','Solomon','Stephen','Stewart','Stone','Stuart','Sylvester','Tad','Tanek','Tarik','Tate','Thaddeus','Thane','Theodore','Thomas','Thor','Timon','Timothy','Tobias','Todd','Trevor','Troy','Tucker','Tyler','Tyrone','Ulric','Ulysses','Upton','Uriah','Uriel','Valentine','Vance','Vaughan','Vernon','Victor','Vincent','Vladimir','Wade','Walker','Wallace','Walter','Wang','Warren','Wayne','William','Wing','Wylie','Xander','Xanthus','Xavier','Xenos','Xerxes','Yardley','Yasir','Yoshio','Yuli','Zachery','Zane','Zeph','Zephania');
declare variable $MALE-FIRST-NAMES-COUNT := fn:count($MALE-FIRST-NAMES);

declare variable $FEMALE-FIRST-NAMES := ('Abigail','Abra','Adara','Adele','Adria','Adrienne','Aiko','Aileen','Aimee','Alana','Alea','Alexis','Alfreda','Alice','Aline','Alisa','Allegra','Alma','Althea','Amanda','Amela','Amelia','Amena','Amity','Amy','Anastasia','Angela','Angelica','Ann','Anne','Aphrodite','April','Aretha','Ariel','Ashely','Athena','Aubrey','Audrey','Aurelia','Aurora','Autumn','Ava','Avye','Ayanna','Barbara','Basia','Beatrice','Bell','Belle','Bertha','Bethany','Beverly','Bianca','Blair','Blythe','Bo','Bree','Brenda','Brenna','Brianna','Brielle','Britanney','Brooke','Bryar','Brynne','Buffy','Cailin','Calista','Callie','Cally','Cameron','Camille','Candace','Candice','Cara','Carissa','Carla','Carol','Caryn','Casey','Cassady','Cassandra','Cassidy','Catherine','Cecilia','Chantale','Charde','Charissa','Chastity','Chava','Chelsea','Cheyenne','Chiquita','Chloe','Christine','Claire','Clare','Claudia','Clementine','Cleo','Clio','Colette','Cora','Cynthia','Dahlia','Dai','Dakota','Danielle','Daphne','Dara','Darrel','Darryl','Dawn','Deanna','Deborah','Deirdre','Delilah','Demetria','Denise','Desiree','Destiny','Dominique','Donna','Dora','Doris','Ebony','Echo','Eden','Elaine','Eleanor','Eliana','Elizabeth','Ella','Emerald','Emi','Emily','Emma','Erica','Erin','Eugenia','Evangeline','Eve','Evelyn','Faith','Fallon','Farrah','Fay','Felicia','Fiona','Fleur','Florence','Frances','Francesca','Gail','Galena','Gemma','Georgia','Germaine','Germane','Gillian','Ginger','Gisela','Giselle','Glenna','Gloria','Grace','Guinevere','Gwendolyn','Hadassah','Hadley','Haley','Hanae','Hanna','Harriet','Haviva','Hayfa','Heather','Hedwig','Hedy','Helen','Hilary','Hilda','Hillary','Hiroko','Hollee','Holly','Hope','Idona','Ifeoma','Ignacia','Ila','Illana','Illiana','Ima','Imani','Imelda','Imogene','Ina','India','Inez','Inga','Ingrid','Iola','Iona','Irene','Iris','Irma','Isabella','Isabelle','Isadora','Ivana','Ivy','Jada','Jaden','Jaime','Jane','Jaquelyn','Jasmine','Jayme','Jeanette','Jena','Jenette','Jennifer','Jescie','Jillian','Jolene','Jolie','Jordan','Jorden','Josephine','Joy','Judith','Juliet','Justina','Justine','Kaden','Kai','Kaitlin','Kalia','Kameko','Karen','Karina','Karleigh','Karly','Karyn','Katell','Kaye','Keelie','Keely','Keiko','Kellie','Kelly','Kelsie','Kendall','Kerry','Kessie','Kevyn','Kiara','Kiayada','Kim','Kimberley','Kimberly','Kiona','Kirby','Kirestin','Kitra','Kristen','Kylan','Kylee','Kylie','Kylynn','Lacey','Lacota','Lacy','Lana','Lani','Lara','Lareina','Larissa','Latifah','Laura','Laurel','Lavinia','Leah','Leandra','Lee','Leigh','Leila','Leilani','Lenore','Leslie','Libby','Liberty','Lila','Lilah','Lillith','Linda','Lois','Lucy','Lydia','Lysandra','MacKensie','MacKenzie','Madaline','Madeline','Madeson','Madison','Madonna','Maggie','Maggy','Maia','Maile','Maisie','Mallory','Mara','Marah','Marcia','Margaret','Mari','Mariko','Marny','Martena','Martha','Martina','Mary','Maryam','Maxine','May','Maya','McKenzie','Mechelle','Medge','Megan','Meghan','Melanie','Melinda','Melissa','Melodie','Melyssa','Meredith','Mia','Michelle','Mikayla','Minerva','Miranda','Moana','Mollie','Molly','Mona','Morgan','Nadine','Naomi','Nelle','Nerea','Nevada','Neve','Nichole','Nicole','Nina','Noel','Noelani','Noelle','Nola','Nomlanga','Nora','Nyssa','Octavia','Odessa','Odette','Olga','Olivia','Olympia','Oprah','Ora','Ori','Orla','Orli','Pandora','Pascale','Patience','Patricia','Paula','Pearl','Penelope','Petra','Phoebe','Phyllis','Piper','Portia','Priscilla','Quail','Quin','Quincy','Quinn','Quintessa','Quon','Quyn','Quynn','Rachel','Rae','Ramona','Rana','Raya','Reagan','Rebecca','Rebekah','Regan','Regina','Remedios','Renee','Rhea','Rhiannon','Rhoda','Rhonda','Ria','Riley','Rinah','Risa','Roanna','Robin','Rosalyn','Rose','Ruby','Rylee','Sacha','Sade','Sage','Samantha','Sara','Sarah','Sasha','Savannah','Scarlet','Scarlett','Selma','September','Serena','Serina','Shaeleigh','Shaine','Shannon','Shay','Shea','Sheila','Shelby','Shelley','Shelly','Shoshana','Sierra','Signe','Simone','Skyler','Sloane','Sonia','Sophia','Sopoline','Stacey','Stella','Stephanie','Summer','Susan','Sybil','Sybill','Sydnee','Sydney','Sylvia','Tamekah','Tanisha','Tanya','Tashya','TaShya','Tatiana','Tatum','Tatyana','Teagan','Uma','Unity','Urielle','Ursula','Vanna','Veda','Velma','Veronica','Violet','Virginia','Vivian','Vivien','Wanda','Whilemina','Whoopi','Willa','Willow','Wilma','Winifred','Wynne','Wynter','Wyoming','Xantha','Xaviera','Xena','Xerxes','Xyla','Yael','Yen','Yeo','Yolanda','Yoshi','Yuri','Yvette','Yvonne','Zelda','Zelenia','Zena','Zenaida','Zenia','Zephr','Zia','Zorita');
declare variable $FEMALE-FIRST-NAMES-COUNT := fn:count($FEMALE-FIRST-NAMES);

declare variable $MIDDLE-NAMES := ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
declare variable $MIDDLE-NAMES-COUNT := fn:count($MIDDLE-NAMES);

declare variable $LAST-NAMES := ('Abbott', 'Acevedo', 'Acosta', 'Adams', 'Adkins', 'Aguilar', 'Aguirre', 'Albert', 'Alexander', 'Alford', 'Allen', 'Allison', 'Alston', 'Alvarado', 'Alvarez', 'Anderson', 'Andrews', 'Anthony', 'Armstrong', 'Arnold', 'Ashley', 'Atkins', 'Atkinson', 'Austin', 'Avery', 'Avila', 'Ayala', 'Ayers', 'Bailey', 'Baird', 'Baker', 'Baldwin', 'Ball', 'Ballard', 'Banks', 'Barber', 'Barker', 'Barlow', 'Barnes', 'Barnett', 'Barr', 'Barrera', 'Barrett', 'Barron', 'Barry', 'Bartlett', 'Barton', 'Bass', 'Bates', 'Battle', 'Bauer', 'Baxter', 'Beach', 'Bean', 'Beard', 'Beasley', 'Beck', 'Becker', 'Bell', 'Bender', 'Benjamin', 'Bennett', 'Benson', 'Bentley', 'Benton', 'Berg', 'Berger', 'Bernard', 'Berry', 'Best', 'Bird', 'Bishop', 'Black', 'Blackburn', 'Blackwell', 'Blair', 'Blake', 'Blanchard', 'Blankenship', 'Blevins', 'Bolton', 'Bond', 'Bonner', 'Booker', 'Boone', 'Booth', 'Bowen', 'Bowers', 'Bowman', 'Boyd', 'Boyer', 'Boyle', 'Bradford', 'Bradley', 'Bradshaw', 'Brady', 'Branch', 'Bray', 'Brennan', 'Brewer', 'Bridges', 'Briggs', 'Bright', 'Britt', 'Brock', 'Brooks', 'Brown', 'Browning', 'Bruce', 'Bryan', 'Bryant', 'Buchanan', 'Buck', 'Buckley', 'Buckner', 'Bullock', 'Burch', 'Burgess', 'Burke', 'Burks', 'Burnett', 'Burns', 'Burris', 'Burt', 'Burton', 'Bush', 'Butler', 'Byers', 'Byrd', 'Cabrera', 'Cain', 'Calderon', 'Caldwell', 'Calhoun', 'Callahan', 'Camacho', 'Cameron', 'Campbell', 'Campos', 'Cannon', 'Cantrell', 'Cantu', 'Cardenas', 'Carey', 'Carlson', 'Carney', 'Carpenter', 'Carr', 'Carrillo', 'Carroll', 'Carson', 'Carter', 'Carver', 'Case', 'Casey', 'Cash', 'Castaneda', 'Castillo', 'Castro', 'Cervantes', 'Chambers', 'Chan', 'Chandler', 'Chaney', 'Chang', 'Chapman', 'Charles', 'Chase', 'Chavez', 'Chen', 'Cherry', 'Christensen', 'Christian', 'Church', 'Clark', 'Clarke', 'Clay', 'Clayton', 'Clements', 'Clemons', 'Cleveland', 'Cline', 'Cobb', 'Cochran', 'Coffey', 'Cohen', 'Cole', 'Coleman', 'Collier', 'Collins', 'Colon', 'Combs', 'Compton', 'Conley', 'Conner', 'Conrad', 'Contreras', 'Conway', 'Cook', 'Cooke', 'Cooley', 'Cooper', 'Copeland', 'Cortez', 'Cote', 'Cotton', 'Cox', 'Craft', 'Craig', 'Crane', 'Crawford', 'Crosby', 'Cross', 'Cruz', 'Cummings', 'Cunningham', 'Curry', 'Curtis', 'Dale', 'Dalton', 'Daniel', 'Daniels', 'Daugherty', 'Davenport', 'David', 'Davidson', 'Davis', 'Dawson', 'Day', 'Dean', 'Decker', 'Dejesus', 'Delacruz', 'Delaney', 'Deleon', 'Delgado', 'Dennis', 'Diaz', 'Dickerson', 'Dickson', 'Dillard', 'Dillon', 'Dixon', 'Dodson', 'Dominguez', 'Donaldson', 'Donovan', 'Dorsey', 'Dotson', 'Douglas', 'Downs', 'Doyle', 'Drake', 'Dudley', 'Duffy', 'Duke', 'Duncan', 'Dunlap', 'Dunn', 'Duran', 'Durham', 'Dyer', 'Eaton', 'Edwards', 'Elliott', 'Ellis', 'Ellison', 'Emerson', 'England', 'English', 'Erickson', 'Espinoza', 'Estes', 'Estrada', 'Evans', 'Everett', 'Ewing', 'Farley', 'Farmer', 'Farrell', 'Faulkner', 'Ferguson', 'Fernandez', 'Ferrell', 'Fields', 'Figueroa', 'Finch', 'Finley', 'Fischer', 'Fisher', 'Fitzgerald', 'Fitzpatrick', 'Fleming', 'Fletcher', 'Flores', 'Flowers', 'Floyd', 'Flynn', 'Foley', 'Forbes', 'Ford', 'Foreman', 'Foster', 'Fowler', 'Fox', 'Francis', 'Franco', 'Frank', 'Franklin', 'Franks', 'Frazier', 'Frederick', 'Freeman', 'French', 'Frost', 'Fry', 'Frye', 'Fuentes', 'Fuller', 'Fulton', 'Gaines', 'Gallagher', 'Gallegos', 'Galloway', 'Gamble', 'Garcia', 'Gardner', 'Garner', 'Garrett', 'Garrison', 'Garza', 'Gates', 'Gay', 'Gentry', 'George', 'Gibbs', 'Gibson', 'Gilbert', 'Giles', 'Gill', 'Gillespie', 'Gilliam', 'Gilmore', 'Glass', 'Glenn', 'Glover', 'Goff', 'Golden', 'Gomez', 'Gonzales', 'Gonzalez', 'Good', 'Goodman', 'Goodwin', 'Gordon', 'Gould', 'Graham', 'Grant', 'Graves', 'Gray', 'Green', 'Greene', 'Greer', 'Gregory', 'Griffin', 'Griffith', 'Grimes', 'Gross', 'Guerra', 'Guerrero', 'Guthrie', 'Gutierrez', 'Guy', 'Guzman', 'Hahn', 'Hale', 'Haley', 'Hall', 'Hamilton', 'Hammond', 'Hampton', 'Hancock', 'Haney', 'Hansen', 'Hanson', 'Hardin', 'Harding', 'Hardy', 'Harmon', 'Harper', 'Harrell', 'Harrington', 'Harris', 'Harrison', 'Hart', 'Hartman', 'Harvey', 'Hatfield', 'Hawkins', 'Hayden', 'Hayes', 'Haynes', 'Hays', 'Head', 'Heath', 'Hebert', 'Henderson', 'Hendricks', 'Hendrix', 'Henry', 'Hensley', 'Henson', 'Herman', 'Hernandez', 'Herrera', 'Herring', 'Hess', 'Hester', 'Hewitt', 'Hickman', 'Hicks', 'Higgins', 'Hill', 'Hines', 'Hinton', 'Hobbs', 'Hodge', 'Hodges', 'Hoffman', 'Hogan', 'Holcomb', 'Holden', 'Holder', 'Holland', 'Holloway', 'Holman', 'Holmes', 'Holt', 'Hood', 'Hooper', 'Hoover', 'Hopkins', 'Hopper', 'Horn', 'Horne', 'Horton', 'House', 'Houston', 'Howard', 'Howe', 'Howell', 'Hubbard', 'Huber', 'Hudson', 'Huff', 'Huffman', 'Hughes', 'Hull', 'Humphrey', 'Hunt', 'Hunter', 'Hurley', 'Hurst', 'Hutchinson', 'Hyde', 'Ingram', 'Irwin', 'Jackson', 'Jacobs', 'Jacobson', 'James', 'Jarvis', 'Jefferson', 'Jenkins', 'Jennings', 'Jensen', 'Jimenez', 'Johns', 'Johnson', 'Johnston', 'Jones', 'Jordan', 'Joseph', 'Joyce', 'Joyner', 'Juarez', 'Justice', 'Kane', 'Kaufman', 'Keith', 'Keller', 'Kelley', 'Kelly', 'Kemp', 'Kennedy', 'Kent', 'Kerr', 'Key', 'Kidd', 'Kim', 'King', 'Kinney', 'Kirby', 'Kirk', 'Kirkland', 'Klein', 'Kline', 'Knapp', 'Knight', 'Knowles', 'Knox', 'Koch', 'Kramer', 'Lamb', 'Lambert', 'Lancaster', 'Landry', 'Lane', 'Lang', 'Langley', 'Lara', 'Larsen', 'Larson', 'Lawrence', 'Lawson', 'Le', 'Leach', 'Leblanc', 'Lee', 'Leon', 'Leonard', 'Lester', 'Levine', 'Levy', 'Lewis', 'Lindsay', 'Lindsey', 'Little', 'Livingston', 'Lloyd', 'Logan', 'Long', 'Lopez', 'Lott', 'Love', 'Lowe', 'Lowery', 'Lucas', 'Luna', 'Lynch', 'Lynn', 'Lyons', 'Macdonald', 'Macias', 'Mack', 'Madden', 'Maddox', 'Maldonado', 'Malone', 'Mann', 'Manning', 'Marks', 'Marquez', 'Marsh', 'Marshall', 'Martin', 'Martinez', 'Mason', 'Massey', 'Mathews', 'Mathis', 'Matthews', 'Maxwell', 'May', 'Mayer', 'Maynard', 'Mayo', 'Mays', 'Mcbride', 'Mccall', 'Mccarthy', 'Mccarty', 'Mcclain', 'Mcclure', 'Mcconnell', 'Mccormick', 'Mccoy', 'Mccray', 'Mccullough', 'Mcdaniel', 'Mcdonald', 'Mcdowell', 'Mcfadden', 'Mcfarland', 'Mcgee', 'Mcgowan', 'Mcguire', 'Mcintosh', 'Mcintyre', 'Mckay', 'Mckee', 'Mckenzie', 'Mckinney', 'Mcknight', 'Mclaughlin', 'Mclean', 'Mcleod', 'Mcmahon', 'Mcmillan', 'Mcneil', 'Mcpherson', 'Meadows', 'Medina', 'Mejia', 'Melendez', 'Melton', 'Mendez', 'Mendoza', 'Mercado', 'Mercer', 'Merrill', 'Merritt', 'Meyer', 'Meyers', 'Michael', 'Middleton', 'Miles', 'Miller', 'Mills', 'Miranda', 'Mitchell', 'Molina', 'Monroe', 'Montgomery', 'Montoya', 'Moody', 'Moon', 'Mooney', 'Moore', 'Morales', 'Moran', 'Moreno', 'Morgan', 'Morin', 'Morris', 'Morrison', 'Morrow', 'Morse', 'Morton', 'Moses', 'Mosley', 'Moss', 'Mueller', 'Mullen', 'Mullins', 'Munoz', 'Murphy', 'Murray', 'Myers', 'Nash', 'Navarro', 'Neal', 'Nelson', 'Newman', 'Newton', 'Nguyen', 'Nichols', 'Nicholson', 'Nielsen', 'Nieves', 'Nixon', 'Noble', 'Noel', 'Nolan', 'Norman', 'Norris', 'Norton', 'Nunez', 'Obrien', 'Ochoa', 'Oconnor', 'Odom', 'Odonnell', 'Oliver', 'Olsen', 'Olson', 'Oneal', 'Oneil', 'Oneill', 'Orr', 'Ortega', 'Ortiz', 'Osborn', 'Osborne', 'Owen', 'Owens', 'Pace', 'Pacheco', 'Padilla', 'Page', 'Palmer', 'Park', 'Parker', 'Parks', 'Parrish', 'Parsons', 'Pate', 'Patel', 'Patrick', 'Patterson', 'Patton', 'Paul', 'Payne', 'Pearson', 'Peck', 'Pena', 'Pennington', 'Perez', 'Perkins', 'Perry', 'Peters', 'Petersen', 'Peterson', 'Petty', 'Phelps', 'Phillips', 'Pickett', 'Pierce', 'Pittman', 'Pitts', 'Pollard', 'Poole', 'Pope', 'Porter', 'Potter', 'Potts', 'Powell', 'Powers', 'Pratt', 'Preston', 'Price', 'Prince', 'Pruitt', 'Puckett', 'Pugh', 'Quinn', 'Ramirez', 'Ramos', 'Ramsey', 'Randall', 'Randolph', 'Rasmussen', 'Ratliff', 'Ray', 'Raymond', 'Reed', 'Reese', 'Reeves', 'Reid', 'Reilly', 'Reyes', 'Reynolds', 'Rhodes', 'Rice', 'Rich', 'Richard', 'Richards', 'Richardson', 'Richmond', 'Riddle', 'Riggs', 'Riley', 'Rios', 'Rivas', 'Rivera', 'Rivers', 'Roach', 'Robbins', 'Roberson', 'Roberts', 'Robertson', 'Robinson', 'Robles', 'Rocha', 'Rodgers', 'Rodriguez', 'Rodriquez', 'Rogers', 'Rojas', 'Rollins', 'Roman', 'Romero', 'Rosa', 'Rosales', 'Rosario', 'Rose', 'Ross', 'Roth', 'Rowe', 'Rowland', 'Roy', 'Ruiz', 'Rush', 'Russell', 'Russo', 'Rutledge', 'Ryan', 'Salas', 'Salazar', 'Salinas', 'Sampson', 'Sanchez', 'Sanders', 'Sandoval', 'Sanford', 'Santana', 'Santiago', 'Santos', 'Sargent', 'Saunders', 'Savage', 'Sawyer', 'Schmidt', 'Schneider', 'Schroeder', 'Schultz', 'Schwartz', 'Scott', 'Sears', 'Sellers', 'Serrano', 'Sexton', 'Shaffer', 'Shannon', 'Sharp', 'Sharpe', 'Shaw', 'Shelton', 'Shepard', 'Shepherd', 'Sheppard', 'Sherman', 'Shields', 'Short', 'Silva', 'Simmons', 'Simon', 'Simpson', 'Sims', 'Singleton', 'Skinner', 'Slater', 'Sloan', 'Small', 'Smith', 'Snider', 'Snow', 'Snyder', 'Solis', 'Solomon', 'Sosa', 'Soto', 'Sparks', 'Spears', 'Spence', 'Spencer', 'Stafford', 'Stanley', 'Stanton', 'Stark', 'Steele', 'Stein', 'Stephens', 'Stephenson', 'Stevens', 'Stevenson', 'Stewart', 'Stokes', 'Stone', 'Stout', 'Strickland', 'Strong', 'Stuart', 'Suarez', 'Sullivan', 'Summers', 'Sutton', 'Swanson', 'Sweeney', 'Sweet', 'Sykes', 'Talley', 'Tanner', 'Tate', 'Taylor', 'Terrell', 'Terry', 'Thomas', 'Thompson', 'Thornton', 'Tillman', 'Todd', 'Torres', 'Townsend', 'Tran', 'Travis', 'Trevino', 'Trujillo', 'Tucker', 'Turner', 'Tyler', 'Tyson', 'Underwood', 'Valdez', 'Valencia', 'Valentine', 'Valenzuela', 'Vance', 'Vang', 'Vargas', 'Vasquez', 'Vaughan', 'Vaughn', 'Vazquez', 'Vega', 'Velasquez', 'Velazquez', 'Velez', 'Villarreal', 'Vincent', 'Vinson', 'Wade', 'Wagner', 'Walker', 'Wall', 'Wallace', 'Waller', 'Walls', 'Walsh', 'Walter', 'Walters', 'Walton', 'Ward', 'Ware', 'Warner', 'Warren', 'Washington', 'Waters', 'Watkins', 'Watson', 'Watts', 'Weaver', 'Webb', 'Weber', 'Webster', 'Weeks', 'Weiss', 'Welch', 'Wells', 'West', 'Wheeler', 'Whitaker', 'White', 'Whitehead', 'Whitfield', 'Whitley', 'Whitney', 'Wiggins', 'Wilcox', 'Wilder', 'Wiley', 'Wilkerson', 'Wilkins', 'Wilkinson', 'William', 'Williams', 'Williamson', 'Willis', 'Wilson', 'Winters', 'Wise', 'Witt', 'Wolf', 'Wolfe', 'Wong', 'Wood', 'Woodard', 'Woods', 'Woodward', 'Wooten', 'Workman', 'Wright', 'Wyatt', 'Wynn', 'Yang', 'Yates', 'York', 'Young', 'Zamora', 'Zimmerman');
declare variable $LAST-NAMES-COUNT := fn:count($LAST-NAMES);

declare variable $ROAD-TYPES := ('Alley', 'Annex', 'Apartment', 'Arcade', 'Avenue', 'Basement', 'Bayou', 'Beach', 'Bend', 'Bluff', 'Bottom', 'Boulevard', 'Branch', 'Bridge', 'Brook', 'Building', 'Burg', 'Bypass', 'Camp', 'Canyon', 'Cape', 'Causeway', 'Center', 'Circle', 'Cliffs', 'Club', 'Corner', 'Corners', 'Course', 'Court', 'Courts', 'Cove', 'Creek', 'Crescent', 'Crossing', 'Dale', 'Dam', 'Department', 'Divide', 'Drive', 'Estate', 'Expressway', 'Extension', 'Falls', 'Ferry', 'Field', 'Fields', 'Flat', 'Floor', 'Ford', 'Forest', 'Forge', 'Fork', 'Forks', 'Fort', 'Freeway', 'Front', 'Gardens', 'Gateway', 'Glen', 'Green', 'Grove', 'Hanger', 'Harbor', 'Haven', 'Heights', 'Highway', 'Hill', 'Hills', 'Hollow', 'Inlet', 'Island', 'Islands', 'Junction', 'Key', 'Knolls', 'Lake', 'Lakes', 'Landing', 'Lane', 'Light', 'Loaf', 'Lobby', 'Locks', 'Lodge', 'Lower', 'Manor', 'Meadows', 'Mill', 'Mills', 'Mission', 'Mount', 'Mountain', 'Neck', 'Office', 'Orchard', 'Parkway', 'Penthouse', 'Pines', 'Place', 'Plain', 'Plains', 'Plaza', 'Point', 'Port', 'Prairie', 'Radial', 'Ranch', 'Rapids', 'Rest', 'Ridge', 'River', 'Road', 'Room', 'Shoal', 'Shoals', 'Shore', 'Shores', 'Space', 'Spring', 'Springs', 'Square', 'Station', 'Stravenue', 'Stream', 'Street', 'Suite', 'Summit', 'Terrace', 'Trace', 'Track', 'Trafficway', 'Trail', 'Trailer', 'Tunnel', 'Turnpike', 'Union', 'Upper', 'Valley', 'Viaduct', 'View', 'Village', 'Ville', 'Vista', 'Way', 'Wells', 'North', 'South', 'Northeast', 'Southwest', 'East', 'West', 'Southeast', 'Northwest');
declare variable $ROAD-TYPES-COUNT := fn:count($ROAD-TYPES);

declare variable $STREET-NAMES := ('2nd', 'A Street', 'A Street', 'Abbey', 'Abbott', 'Aberdeen', 'Aberdeen', 'Aberdeen', 'Access', 'Access', 'Access', 'Access Road A', 'Acheson', 'Adams', 'Adams', 'Adanak', 'Addenda', 'Adel', 'Adel', 'Admiralty', 'Adrian', 'Aero', 'Afognak', 'Agate', 'Agate', 'Agostino Mine', 'Agostino Mine', 'Air Guard', 'Airport Access', 'Airport Heights', 'Airport Heights', 'Airport Heights', 'Airport Terminal', 'Akula', 'Akutan', 'Alaska', 'Alaska', 'Albatross', 'Albertine', 'Albion', 'Alder', 'Alder', 'Alder', 'Aldren', 'Aleutian', 'Alexander', 'Alice', 'Alice', 'Alitak Bay', 'Allan', 'Alma', 'Alora', 'Alpenglow', 'Alpina', 'Alpina', 'Alpine', 'Alpine', 'Alpine', 'Alpine View', 'Alpine View', 'Alpine Woods', 'Alta', 'Alta', 'Alumni', 'Alumni', 'Alyeska', 'Alyeska', 'Ambassador', 'Ambassador', 'Ambler', 'Amherst', 'Amonson', 'Amys', 'Anchor', 'Anchor', 'Anchor Park', 'Andover', 'Andreanof', 'Ange', 'Angela', 'Annapolis', 'Annette', 'Annette', 'Annette', 'Annette', 'Annie Pearl', 'Ansel', 'Anthem', 'Antioch', 'Antler', 'Antler', 'Anton', 'Anton', 'Anvik', 'Anvik', 'Aphrodite', 'Apollo', 'Apollo', 'Arabian', 'Arabian', 'Arbor', 'Arbor', 'Arborvitae', 'Arborvitae', 'Arca', 'Arctic', 'Arctic', 'Ares', 'Ares', 'Ariel', 'Arlene', 'Arlene', 'Arlene', 'Arlon', 'Arnica', 'Artemus', 'Arthur', 'Arvid', 'Arvid', 'Ascot', 'Ascot', 'Ash', 'Ash', 'Ashley Cove', 'Ashley Cove', 'Aspen', 'Aspen', 'Aspen', 'Aspen', 'Aspen Grove', 'Aspenrose', 'Asterion', 'Astro', 'Astro', 'Atelier', 'Athanasius', 'Athens', 'Atka', 'Atkinson', 'Atkinson', 'Attiki', 'Attiki', 'Attu', 'Atwood', 'Audubon', 'Augusta', 'Aurora', 'Aurora', 'Austin', 'Avalanche', 'Avalanche', 'Avalanche', 'Avalanche', 'Avalon', 'Avicon', 'Avion', 'B', 'B', 'B', 'Baidarka', 'Baidarka', 'Bailey', 'Bainbridge', 'Balandra', 'Banbury', 'Banff', 'Banff', 'Banff', 'Banff', 'Banff', 'Banff Springs', 'Banff Springs', 'Banner', 'Banner', 'Bannister', 'Bannister', 'Bannister', 'Barbara', 'Barclay', 'Barclay', 'Barnett', 'Baronik', 'Baronik', 'Baronik', 'Barrington', 'Barsiel', 'Barsiel', 'Baxter', 'Baxter', 'Baxter', 'Baxter', 'Baxter Crest', 'Baxter Crest', 'Baxter Crest', 'Bay View', 'Bay View', 'Bayshore', 'Beach', 'Beach Lake', 'Beachwood', 'Beachwood', 'Beachwood', 'Bear Mountain View', 'Bear Paw', 'Beardslee', 'Bearfoot', 'Beaufort', 'Beaujolais', 'Beaujolais', 'Beaumont', 'Beaumont', 'Beaver', 'Beaver', 'Beaver', 'Beaver View', 'Becky', 'Bedford Chase', 'Beechcraft', 'Beechcraft', 'Beechey Point', 'Beeman', 'Beer Can Lake', 'Beer Can Lake', 'Beirne', 'Belarde', 'Belarde', 'Belarde', 'Belduque', 'Bell', 'Bellanca', 'Belmont', 'Belsey', 'Ben', 'Bench', 'Bendilent', 'Bendilent', 'Bennett', 'Bennett', 'Bennett', 'Bennington', 'Benz', 'Bernard', 'Berry', 'Berryhill', 'Bert', 'Betula', 'Beverly', 'Beverly', 'Bietinger', 'Big Sky', 'Big Sky', 'Biglerville', 'Bilbo', 'Bill', 'Bill', 'Bill Stephens', 'Bill Stephens', 'Billys Alley', 'Biorka', 'Birch', 'Birch', 'Birch', 'Birch', 'Birch', 'Birch Hills', 'Birch Run', 'Birch Run', 'Birch Run', 'Birchbark', 'Birchwood', 'Biscayne', 'Black Bear', 'Black Pine', 'Blackberry', 'Blackburn', 'Blackburn', 'Blacktail', 'Blue', 'Blue Skies', 'Blue Spruce', 'Blueberry', 'Blueberry', 'Bluffwood', 'Bobbie', 'Boeing', 'Bogoy', 'Bolin', 'Bona Kim', 'Bona Kim', 'Boniface', 'Bonnie', 'Bonnielaine', 'Bonnielaine', 'Boom', 'Borealis', 'Borealis', 'Borland', 'Botanical', 'Botanical Heights', 'Bothwell', 'Boulder', 'Bow', 'Bowery', 'Boyd', 'Boysen Berry', 'Bradford', 'Bradford', 'Bradley', 'Bradley', 'Bragaw Square', 'Bragaw Square', 'Branche', 'Brandy', 'Brandywine', 'Brandywine', 'Brandywine', 'Brandywine', 'Brant', 'Brayton', 'Brayton', 'Brayton', 'Bree', 'Bree', 'Breeze', 'Breezewood', 'Brenner', 'Brenner', 'Brentwood', 'Brentwood', 'Brewsters', 'Briar', 'Briar', 'Briarcliff', 'Briarcliff Pointe', 'Briarwood', 'Bridget', 'Bridgeview', 'Bridgeview', 'Bridle', 'Bridle', 'Brink', 'Briny', 'Bristol', 'Brittany', 'Brittany', 'Brittany', 'Brittany', 'Broaddus', 'Broadwater', 'Brook Hill', 'Brooke', 'Brookridge', 'Brookridge', 'Brookridge', 'Brookside', 'Brookview', 'Brown', 'Brown', 'Brown Tree', 'Brown Tree', 'Bruce', 'Bruce', 'Bruce', 'Bryan', 'Bryant Ridge', 'Bryn Mawr', 'Buckner', 'Buckner', 'Buddy Werner', 'Buffalo', 'Bugle', 'Bulen', 'Bumpy', 'Bunn', 'Bunnell', 'Burl', 'Burlington', 'Burlington', 'Bursiel', 'Bursiel', 'Butte', 'Butte', 'Buttermilk', 'Buttress Haul', 'Byrd', 'C', 'Cache', 'Cadmus', 'Calais', 'Calamity', 'Cam Island', 'Cam Island', 'Cam Island', 'Camai', 'Camden', 'Cameron', 'Camino', 'Campbell Airstrip', 'Campbell Creek', 'Campbell Creek Science Center', 'Campbell Creek Science Center', 'Campbell Park', 'Campbell Terrace', 'Campus', 'Camrose', 'Candy', 'Candywine', 'Cange', 'Cannon Woods', 'Canterbury', 'Cantonment', 'Cantonment', 'Canyon View', 'Canyon View', 'Cape', 'Cape Lisburne', 'Cape Lisburne', 'Caplina', 'Capricorn', 'Captain Cook Estates', 'Caravelle', 'Caravelle', 'Cardigan', 'Cardinal', 'Career Center', 'Career Center', 'Caress', 'Caribou', 'Caribou', 'Caribou Hill', 'Carleton', 'Carlin', 'Carlina', 'Carlos', 'Carnaby', 'Carnaby', 'Carnaby', 'Caro', 'Carolyn', 'Carousel', 'Carrs Muldoon Access', 'Cascade', 'Casey Cusack', 'Caswell', 'Caswell', 'Cates', 'Cates', 'Cates', 'Catherine', 'Catherine', 'Cathy', 'Catine', 'Catkin', 'Cc', 'Cecilia', 'Cedar', 'Cedar Park', 'Celestial', 'Center', 'Centerfield', 'Centerpoint', 'Cervin', 'Chaimi', 'Chalet', 'Chalet', 'Charity', 'Charlie', 'Charter', 'Chateau', 'Chateau Trailer', 'Checkmate', 'Cheechako', 'Cheechako', 'Cheelys', 'Chelea', 'Chelsea', 'Chelsea', 'Chena', 'Chena', 'Chenoweth', 'Cherokee', 'Cherry', 'Chesapeake', 'Chesapeake', 'Chesapeake', 'Chester', 'Chester', 'Chestnut', 'Chevigny', 'Cheyenne', 'Chickadee', 'Chickaloon', 'Chickweed', 'Chilkat', 'Chilkat', 'Chilkat', 'Chilkoot', 'Chilkoot', 'Chilkoot', 'Chilligan', 'Chilton', 'Chilton', 'Chilton', 'Chilton', 'Chilton', 'Chilton', 'China Berry', 'China Berry', 'Chipper Tree', 'Chirikof', 'Chirikof', 'Chisana', 'Chisana', 'Chisana', 'Chisana', 'Chisik', 'Chitstone Mountain', 'Chokecherry', 'Chris', 'Chris', 'Christensen', 'Christine', 'Christopher', 'Chuck', 'Chugach Dr Trailer', 'Chugiak', 'Chugiak', 'Cicutta', 'Cimarron', 'Cimarron', 'Cinerama', 'Cinnabar', 'Circle', 'Circlewood', 'Circlewood', 'Cirque', 'Cirrus', 'Citadel', 'Clairborne', 'Clairborne', 'Clarbert', 'Claridge', 'Clarks', 'Clay', 'Clay Products', 'Clear Haven', 'Clear Haven', 'Clemens', 'Clerke', 'Cliff', 'Cline', 'Clint', 'Cloudberry', 'Cloudberry', 'Cobblestone', 'Cobblestone Hill', 'Cobra', 'Cody', 'Colchis', 'Coleman', 'Coleman', 'College Meadow', 'Collins', 'Collins', 'Colony', 'Colony', 'Columbia', 'Columbine', 'Colville', 'Colwell', 'Comet', 'Commander Row', 'Commerce', 'Commercial', 'Compass', 'Concord', 'Concord', 'Constellation', 'Constitution', 'Constitution', 'Constitution', 'Cook Inlet', 'Copper', 'Copper Mountain', 'Coral', 'Coral', 'Coral', 'Coral Reef', 'Cordell', 'Cordova', 'Core', 'Core', 'Cork', 'Cormorant Cove', 'Cormorant Cove', 'Cornell', 'Coronado', 'Coronado', 'Cortina', 'Corvus', 'Cosmic', 'Cottonwood', 'Cottonwood', 'Coughlan', 'Coughlan', 'Country Club', 'Country Lake', 'Country Lake', 'Country View', 'Coventry', 'Coventry', 'Covington', 'Craig', 'Craig', 'Craig', 'Craig Creek', 'Craig Creek', 'Craiger', 'Cramer', 'Cranberry', 'Crannog', 'Crataegus', 'Crataegus', 'Crawford', 'Creek', 'Creek', 'Creek', 'Creekside', 'Cremins', 'Crescent', 'Crescent', 'Crescent', 'Crescent', 'Crescent Moon', 'Crescent Moon', 'Crested Butte', 'Crestline', 'Crestwood', 'Crillon', 'Criswell', 'Crooked Tree', 'Cross', 'Cross', 'Cross Pointe', 'Crosson', 'Crow Creek', 'Crow Creek Mine', 'Crowberry', 'Crows Nest', 'Crystal Mountain', 'Crystal Mountain', 'Culhane', 'Culver', 'Culver', 'Cumberland', 'Cumulus', 'Cumulus', 'Cunningham', 'Cunningham', 'Curlew', 'Curlew', 'Currin', 'Currin', 'Curt', 'Curtis', 'Cutlass', 'Cyrus', 'Dagan', 'Dahl', 'Dahl', 'Dailey', 'Damman', 'Dana', 'Danner', 'Danny', 'Danny', 'Darby', 'Darby', 'Darby', 'Darlon', 'Darn', 'Dartmouth', 'Dartmouth', 'David', 'David', 'David', 'David', 'David Blackburn', 'Davidson', 'Davis', 'Davis', 'Davis', 'Davis', 'Davis', 'Davos', 'Dawn', 'Dawn', 'Dawn', 'Dawnlight', 'Dawnlight', 'Daybreak', 'Daybreak', 'Dayton', 'De Havilland', 'Debarr', 'Debbie', 'Debbie', 'Debbie', 'Deborah Lynn', 'Deborah Lynn', 'Deborah Lynn', 'Deer', 'Deer Park', 'Deer Park', 'Deerfield', 'Deerfield', 'Delasala', 'Delong', 'Delores', 'Delridge', 'Delta', 'Delta', 'Delwood', 'Denaina', 'Denali View', 'Denson', 'Derby', 'Desiree', 'Diana', 'Dickson', 'Diomede', 'Diplomacy', 'Diplomacy', 'Discovery Heights', 'Discovery View', 'Division', 'Division', 'Dixie', 'Doctor Martin Luther King Junior', 'Doctor Martin Luther King Junior', 'Dogwood', 'Dolina', 'Dolly', 'Dolly Madison', 'Dolly Varden', 'Dolly Varden', 'Dolly Varden', 'Dolly Varden', 'Domain', 'Dome', 'Donald', 'Donald', 'Donalds', 'Donalds', 'Donington', 'Donington', 'Dorchester', 'Dorian', 'Dorinda', 'Dorothy', 'Dos', 'Dotty', 'Dotty', 'Douglas', 'Douglas', 'Downey Finch', 'Downey Finch', 'Drake', 'Driftwood', 'Driftwood', 'Drum', 'Duben', 'Duke', 'Dunbar', 'Dundee', 'Dunlap', 'Dunsmuir', 'E', 'E', 'Eagle River', 'Eagle River', 'Eaglek Bay', 'Eaglewood', 'Earl', 'Early View', 'East 102nd', 'East 10th', 'East 112th', 'East 112th', 'East 113th', 'East 114th', 'East 115th', 'East 118th', 'East 11th', 'East 135th', 'East 144th', 'East 144th', 'East 144th', 'East 14th', 'East 14th', 'East 150th', 'East 15th', 'East 15th', 'East 15th', 'East 164th', 'East 164th', 'East 16th', 'East 18th', 'East 18th', 'East 18th', 'East 19th', 'East 24th', 'East 25th', 'East 25th', 'East 28th', 'East 2nd', 'East 2nd', 'East 31st', 'East 34th', 'East 34th', 'East 37th', 'East 38th', 'East 39th', 'East 3rd', 'East 41st', 'East 41st', 'East 41st', 'East 42nd', 'East 42nd', 'East 43rd', 'East 43rd', 'East 44th', 'East 45th', 'East 45th', 'East 45th', 'East 46th', 'East 47th', 'East 47th', 'East 47th', 'East 49th', 'East 4th', 'East 52nd', 'East 52nd', 'East 52nd', 'East 54th', 'East 54th', 'East 55th', 'East 57th', 'East 57th', 'East 57th', 'East 58th', 'East 58th', 'East 58th', 'East 59th', 'East 63rd', 'East 63rd', 'East 63rd', 'East 63rd', 'East 63rd', 'East 66th', 'East 67th', 'East 69th', 'East 6th', 'East 70th', 'East 71st', 'East 71st', 'East 74th', 'East 75th', 'East 76th', 'East 76th', 'East 78th', 'East 7th', 'East 83rd', 'East 86th', 'East 86th', 'East 87th', 'East 88th', 'East 8th', 'East 91st', 'East 92nd', 'East 94th', 'East 95th', 'East 95th', 'East 95th', 'East 98th', 'East 9th', 'East Benson', 'East Bluff', 'East Bluff', 'East Chester Heights', 'East Franklin', 'East International Airport', 'East International Airport', 'East Klatt', 'East Klatt', 'East Perimeter', 'East Ship Creek', 'East Ship Creek', 'East Tree', 'East Tree', 'East Tree', 'East Tudor', 'East Tudor', 'East View', 'East Zeus', 'East Zeus', 'Eastbrook', 'Eastbrook', 'Easter Island', 'Eastgate', 'Eastwind', 'Eastwind', 'Eastwood', 'Eau Claire', 'Eau Claire', 'Echo', 'Echo Canyon', 'Echo Ridge', 'Echo Ridge', 'Edgewater', 'Edinburgh', 'Edna', 'Edna', 'Edward', 'Egloff', 'Egloff', 'Egloff', 'Eide', 'Eielson', 'Eklund', 'Eklund', 'Eklutna', 'El Paso', 'Eldora', 'Eleusis', 'Eleusis', 'Eleusis', 'Eleusis', 'Eleusis', 'Eleusis', 'Elkhorn', 'Ellen', 'Elmore', 'Emard', 'Emerald', 'Emerald', 'Emerald', 'Emmanuel', 'Emmanuel', 'Encore', 'Endicott', 'Energy', 'Ephreta', 'Equestrian', 'Eric', 'Erickson', 'Erin', 'Ervin', 'Eshamy Bay', 'Essex Point', 'Estuary', 'Estuary', 'Eureka', 'Evenson', 'Evergreen', 'Excursion', 'Faccio', 'Fairbanks', 'Fairmount', 'Fairweather', 'Fairweather Park', 'Fairweather Park', 'Fairweather Park', 'Falcon', 'Falcon', 'Falklands', 'Fall Leaf', 'Fallow', 'Farm', 'Farmer', 'Farpoint', 'Fergy', 'Ferndale', 'Fernhill', 'Fernhill', 'Filmore', 'Finland', 'Finland', 'Finley', 'Fire Creek Trail', 'Fire Creek Trail', 'Fire Creek Trail', 'Fire Lake', 'Fire Lake', 'Fireball', 'Fireball', 'Firnline', 'Fischer', 'Fish Hatchery', 'Fisher', 'Flagship', 'Flamingo', 'Fleetwood', 'Floatplane', 'Florence', 'Flyfishing', 'Folker', 'Folker', 'Folker', 'Foothill', 'Ford', 'Fordham', 'Forelands', 'Forest Park', 'Forrest', 'Foster', 'Fountain', 'Four Winds', 'Four Winds', 'Four Winds', 'Frances Elaine', 'Francesca', 'Franklin', 'Fred', 'Fred', 'Freedom', 'Freedom', 'Friendly', 'Friendship', 'Frigate', 'Frolick Wind', 'Frontage', 'Fullenwider', 'Fullenwider', 'Fuller', 'Furrow Creek', 'Furrow Creek', 'Furrow Creek', 'Gabes', 'Galactica', 'Galena Bay', 'Galena Bay', 'Galewood', 'Galleon', 'Galleon', 'Galloway', 'Gambell', 'Garden', 'Garmisch', 'Garnet', 'Gary Cooper', 'Gayot', 'Geneva', 'Geneve', 'George', 'Geronimo', 'Giddeon', 'Giddeon', 'Gilbert', 'Gilbert', 'Gill', 'Gilmore', 'Gilmore', 'Ginami', 'Ginger Lee', 'Ginger Lee', 'Ginger Lee', 'Girdwood', 'Girdwood Place', 'Girdwood Place', 'Girdwood Place', 'Giroux', 'Giroux', 'Glacier', 'Glacier', 'Glacier', 'Glacier Loop', 'Glacier Park', 'Glacier Pine', 'Glacier Pine', 'Glacier Terrace', 'Glade', 'Glenkerry', 'Glenn', 'Glenn', 'Glenn', 'Glenn', 'Glenn Hill', 'Glenn Hill', 'Gloucester', 'Goff', 'Gold', 'Gold', 'Gold Claim', 'Gold Kings', 'Golden', 'Golden Spring', 'Goldenview Park', 'Golovin', 'Goodnews', 'Goodnews', 'Goodnews', 'Goose Lake', 'Goose Lake', 'Gordon', 'Gorlanof', 'Gorsuch', 'Grace', 'Graiff', 'Grand Larry', 'Grant', 'Grass Creek', 'Grass Creek', 'Grasser', 'Great Dane', 'Great Dane', 'Great Dane', 'Great North', 'Greece', 'Greece', 'Greenbelt', 'Greenbrook', 'Greenbrook', 'Greenhouse', 'Greenscreek', 'Gregory', 'Gregory', 'Griffin', 'Griffith', 'Grissom', 'Grizzly', 'Grizzly', 'Groh', 'Gross', 'Gross', 'Gstaad', 'Guam', 'Guillemot', 'Gulch', 'Gulch', 'Gulkana', 'Gum', 'Gum', 'Gunnison', 'Gunwale', 'Gwenn', 'H', 'Hacienda', 'Hale', 'Halfhitch', 'Halfhitch', 'Halibut Cove', 'Hall', 'Hall', 'Halleys Comet', 'Halligan Cross', 'Hamann', 'Hammond', 'Hammond', 'Hampshire', 'Hampton', 'Hampton', 'Hampton Green', 'Hampton Green', 'Hancock', 'Hancock', 'Hane', 'Hane', 'Hannah Jane', 'Hannahs', 'Hanning Bay', 'Happy', 'Harbor', 'Harbor Point', 'Harca', 'Harding', 'Hardrock', 'Haricot', 'Harmany Ranch', 'Harry Mc Donald', 'Hartzell', 'Haru', 'Haru', 'Havenshire', 'Havitur', 'Havitur', 'Hayes', 'Hazen', 'Heartwood', 'Heide', 'Heidi', 'Helen', 'Helgelien', 'Helio', 'Helio', 'Helio', 'Helluva', 'Helvetia', 'Henry', 'Henson Drive', 'Herb', 'Heritage', 'Heritage', 'Heritage', 'Heritage Center', 'Heritage Center', 'Heritage Heights', 'Hermes', 'Hermes', 'Hidden', 'Hidden Creek', 'Hidden Point', 'Hidden Point', 'Hidden Retreat', 'Hidden Retreat', 'Hidden Retreat', 'Hidden Retreat', 'Hidden Retreat', 'Hidden View', 'Hidden View', 'Hideaway', 'Hideaway', 'High', 'High Bluff', 'High Bluff', 'High Bluff', 'High Bluff', 'High View', 'Higher', 'Highland', 'Highland', 'Highland', 'Highland', 'Highland Ridge', 'Highlander', 'Hiland', 'Hill', 'Hill', 'Hill', 'Hill', 'Hill View', 'Hill View', 'Hill View', 'Hillandale', 'Hillcrest', 'Hillcrest', 'Hillcrest', 'Hillcrest', 'Hillhaven', 'Hilltop', 'Hilltop', 'Hinkle', 'Hinkle', 'Hinkle', 'Hinkle', 'Hiton', 'Hiton', 'Hogan Bay', 'Hollow', 'Hollow', 'Holly', 'Holly Lynn', 'Hollywood', 'Holman', 'Holmgren', 'Homecrest', 'Hood', 'Hooper', 'Hooper', 'Hopa', 'Hopa', 'Hope', 'Horizon', 'Horseshoe', 'Hosken', 'Hottentot Mine', 'Howe', 'Huckleberry', 'Hudson', 'Hughes', 'Hughes', 'Hulse', 'Hulse', 'Hulse', 'Hunt', 'Hunt', 'Hunt', 'Hunter', 'Hunters', 'Hunters', 'Hunterwood', 'I', 'I', 'Ida', 'Iditarod', 'Illian', 'Illian', 'Image', 'Image', 'Image', 'Image', 'Immelman', 'Independence', 'Industrial', 'Industrial', 'Industry', 'Industry', 'Industry', 'Ingram', 'Inlet', 'Inlet View Trailer', 'Innes', 'Innsbruck', 'Inspiration', 'Inspiration', 'Inspiration', 'Inyo', 'Inyo', 'Inyo', 'Iowa', 'Iowa', 'Ira', 'Ira', 'Irene', 'Iris', 'Ironwood', 'Ivan', 'J-K', 'Jackson', 'Jackson Hole', 'Jacque', 'Jacque', 'Jacque', 'Jacqueline', 'Jaguar', 'Jamestown', 'Jamie', 'Jamie', 'Jamie', 'Jarvis', 'Jayhawk', 'Jayme', 'Jeanne', 'Jeannie', 'Jelinek', 'Jelinek', 'Jem', 'Jem', 'Jennifer', 'Jennifer Ann', 'Jennison', 'Jensen', 'Jesse Lee', 'Jessie', 'Jessie', 'Jessie', 'Jewel Terrace', 'Jewel Terrace', 'Jewel Terrace', 'Jim', 'Jim', 'Joanne', 'Jodhpur', 'Joham', 'John Alden', 'Johnny', 'Joli', 'Jones', 'Jordan', 'Jordan', 'Jordan', 'Jordt', 'Jordt', 'Joy', 'Joy', 'Joy', 'Juanita', 'Judd', 'Judd', 'Judd', 'Juliana', 'Juneau', 'Juneau', 'Juniper', 'Jupiter', 'Jupiter', 'K', 'K And R', 'Kachemak', 'Kahiltna', 'Kalgin', 'Kallander', 'Kalmia', 'Kalmia', 'Kamkoff', 'Kantishna', 'Kantishna', 'Karen', 'Karen', 'Karluk', 'Kaskanak', 'Kaskanak', 'Kaskanak', 'Katalla', 'Kathleen', 'Kathy', 'Kathy', 'Kathy', 'Katmai', 'Katrina', 'Kavik', 'Kavik', 'Kayak', 'Kaylin', 'Keith', 'Kelly Maureen', 'Kelly Ranch', 'Kempton Hills', 'Ken Logan', 'Kenai Fjords', 'Kenai Fjords', 'Kendall', 'Kenny', 'Kent', 'Kently', 'Kently', 'Kepner', 'Kerr', 'Kerr', 'Kerry', 'Kerry', 'Keuka', 'Keuka', 'Kew', 'Kew', 'Keyann', 'Khyber', 'Kiana', 'Kichatna', 'Kichatna', 'Kidron', 'Kigul', 'Kiliak', 'Kiliak', 'Kiliak', 'Kiliak', 'Kilkerry', 'Kilmory', 'Kilo', 'Kiloana', 'Kiloana', 'Kim', 'Kim', 'Kimberlie', 'Kimberlie', 'Kimberlie', 'Kimpton', 'Kimpton', 'Kincaid Estates', 'Kincaid Estates', 'King David', 'Kings Point', 'Kings Point', 'Kingston', 'Kinlien', 'Kinnikinnick', 'Kirby', 'Kirk', 'Kirkwall', 'Kirkwall', 'Kirov', 'Kirov', 'Kirsten', 'Kitlisa', 'Kitlisa', 'Kitzbuhel', 'Klingler', 'Klingler', 'Klondike', 'Klondike', 'Kluane', 'Kluane', 'Klutina', 'Knights', 'Knik', 'Knik Vista', 'Knoll', 'Kobuk', 'Kogru', 'Konrad', 'Konrad', 'Krane', 'Krane', 'Kreinheder', 'Krishka', 'Kristie', 'Kumquat', 'Kuphaldt', 'Kupreanof', 'Kutcher', 'Kutcher', 'Kutchin', 'Kvichak', 'Kwigillingok', 'L', 'L', 'Labate', 'Lace', 'Lacey', 'Lacey', 'Ladd', 'Ladd', 'Lake', 'Lake', 'Lake Clark', 'Lake Clark', 'Lake George', 'Lake Hill', 'Lake O The Hills', 'Lake O The Hills', 'Lake Otis', 'Lake Otis', 'Lake Park', 'Lake Park', 'Lake Shore', 'Lake Spenard', 'Lake Spenard', 'Lake View', 'Lakehurst', 'Lakehurst', 'Lakeridge', 'Lakeridge', 'Lakeshore', 'Lakeshore', 'Lakeshore', 'Lakeway', 'Lakina', 'Lakina', 'Lakina', 'Lamb', 'Lamoreaux', 'Lamoreaux', 'Lampert', 'Lamplighter', 'Lamplighter', 'Lana', 'Lance', 'Lance', 'Lance', 'Lancelot', 'Landings', 'Landings', 'Landmark', 'Lane', 'Lane', 'Lang', 'Langman', 'Langman', 'Larkspur', 'Laron', 'Laron', 'Lars', 'Lars', 'Lars', 'Lassen', 'Lassen', 'Latouche', 'Laughlin', 'Laura', 'Laurel', 'Laurel', 'Lauren Creek', 'Laurence', 'Lawlor', 'Lawlor', 'Lawlor', 'Lawlor', 'Lazuli', 'Lazuli', 'Le Doux', 'Leah', 'Lear', 'Leary Bay', 'Ledora', 'Lee', 'Lee', 'Lee', 'Lee', 'Leeper', 'Leeper', 'Leeward', 'Legacy', 'Legacy', 'Leigh', 'Lennie', 'Lennie', 'Lennox', 'Leo', 'Leopard', 'Lesmer', 'Lewis', 'Libra', 'Libra', 'Lidia Selkregg', 'Lido', 'Lido', 'Lieselotte', 'Lighthouse', 'Lighthouse', 'Lilac', 'Lilleston', 'Limestone', 'Limestone', 'Limestone', 'Lincoln Ellsworth', 'Lindblad', 'Linden', 'Lindsey', 'Lindy', 'Link Brook', 'Lipscomb', 'Lisa', 'List', 'Little Campbell Creek', 'Little Campbell Creek', 'Little Cape', 'Little Creek', 'Little Tree', 'Livingston', 'Livingston', 'Lloyd', 'Lobdell', 'Loc Sault', 'Loc Sault', 'Loch', 'Loch', 'Lochenshire', 'Lodge Pole', 'Log Cabin', 'Loland', 'Lone Tree', 'Long', 'Longbow', 'Longoria', 'Lookout', 'Loon', 'Loon', 'Lore', 'Loren', 'Loren', 'Loretta', 'Lori', 'Lori', 'Lorraine', 'Lott Landing', 'Louinda', 'Louise', 'Lower Kogru', 'Lower Sunny', 'Lower Tulwar', 'Lowland', 'Lucern', 'Lucille', 'Lucy', 'Ludlow', 'Ludlow', 'Ludlow', 'Lugene', 'Lunar', 'Lunar', 'Lupin', 'Lupin', 'Lupin', 'Lupine', 'Lupine', 'Lupine', 'Lupine', 'Lupine', 'Lupine', 'Lupine', 'Lynkerry', 'Lynkerry', 'Lynn', 'Lynn', 'Lynne', 'Lynnwood', 'Lyvona', 'Macalister', 'Macalister', 'Macbeth', 'Macinnes', 'Mackay', 'Maclaren', 'Madigan', 'Magaret Mielke', 'Maggies', 'Magnaview', 'Magnolia', 'Magnolia', 'Maho', 'Main', 'Main', 'Majella', 'Majestic', 'Majestic', 'Makushin Bay', 'Malaspina', 'Malcolm', 'Malcolm', 'Malcolm', 'Malispina Trailer', 'Mammoth', 'Maple', 'Marble', 'Marcy', 'Marion', 'Mark', 'Mark', 'Marston', 'Marten', 'Marthas Vineyard', 'Mary Anne', 'Mary Anne', 'Matilda', 'Matilda', 'Matterhorn', 'Matthew Paul', 'May Court', 'Mayfair', 'Maylen', 'Maylen', 'Mc Cabe Circle', 'Mc Cain', 'Mc Cain', 'Mc Crary', 'Mc Cready', 'Mc Gill', 'Mc Hugh', 'Mc Intyre', 'Mc Intyre', 'Mc Kinley', 'Mc Kinley', 'Mc Manus', 'Mc Phee', 'Mc Phee', 'Meadow', 'Meadow', 'Meadow Canyon', 'Meadow Canyon', 'Meadow Lark', 'Meadow Lark', 'Meadow Ridge', 'Meadow Wood', 'Meander', 'Megeve', 'Megeve', 'Mego', 'Mego', 'Mego', 'Mellow', 'Mellow', 'Mellow', 'Melody', 'Melody', 'Melody Commons', 'Melva', 'Mendocino', 'Mentra', 'Mentra', 'Mentra', 'Meridian', 'Merlin', 'Merrill', 'Merrill', 'Mesquite', 'Mesquite', 'Metz', 'Michael', 'Michaels', 'Michelle', 'Midden', 'Midden', 'Middle', 'Middleton', 'Midland', 'Midvale', 'Midvale', 'Midvale', 'Mile Hi', 'Mile Hi', 'Mile Hi', 'Miles', 'Milky Way', 'Milky Way', 'Milky Way', 'Miller', 'Mills', 'Mills Bay', 'Mills Bay', 'Mills Park', 'Mills Park', 'Miltherrie', 'Mineral', 'Mink', 'Mink', 'Mirage', 'Miranda', 'Misty Falls', 'Misty Glen', 'Misty Glen', 'Misty Mountain', 'Misty Springs', 'Mistybrook', 'Molanary', 'Monastery', 'Monmouth', 'Montagne', 'Montague Bay', 'Montclaire', 'Montego', 'Monterey', 'Monterey', 'Montrose', 'Moody', 'Moonlight', 'Moonstar', 'Mooseberry', 'More', 'Morgan', 'Morning', 'Mount Blanc', 'Mount Hood', 'Mount Mc Kinley', 'Mount Mc Kinley', 'Mount Mc Kinley View', 'Mount Mc Kinley View', 'Mountain', 'Mountain Air', 'Mountain Ash', 'Mountain Breeze', 'Mountain Breeze', 'Mountain Goat', 'Mountain Lake', 'Mountain Lake', 'Mountain Plover', 'Mountain Point', 'Mountain Shadow', 'Mountainside Village', 'Muldoon', 'Muriel', 'Murphy', 'Murphy', 'My', 'Myrtle', 'N', 'N', 'Nadine', 'Nancy', 'Nantucket', 'Nathan', 'Nathan', 'Nathan', 'Natrona', 'Nautilus', 'Nebula', 'Needels', 'Nelchina', 'Nenana', 'New Glenn', 'New Glenn', 'New London', 'New London', 'New Smyrna', 'Newby', 'Newcastle', 'Newcastle', 'Newell', 'Newport', 'Newport', 'Newton', 'Newton', 'Nickleen', 'Nickleen', 'Nielsen', 'Nigh', 'Nikita', 'Nikita', 'Nitoanya', 'Nix', 'Nizki', 'Noble', 'Nora', 'Norak', 'Nordale', 'Norene', 'Norgaard', 'Norgaard', 'Norgaard', 'Norm', 'Norman', 'Norman', 'Normanshire', 'North A', 'North Bragaw', 'North Bragaw', 'North Eagle River Loop', 'North Frontage', 'North Frontage', 'North Juniper', 'North Klevin', 'North Klevin', 'North Mitkof', 'North Montague', 'North Muldoon', 'North Pine', 'North Point', 'North Point', 'North Reeve', 'North River', 'North Salem', 'North Shore', 'North Star', 'North Strand', 'North Valley', 'North Wiley Post', 'North Wrangell', 'Northland', 'Northland', 'Northpointe Bluff', 'Northshore', 'Northway', 'Northwind', 'Northwoods', 'Norton', 'Norton', 'Norway', 'Nottingham', 'Nova', 'Nugget', 'Nulato', 'Nulato', 'Nunaka', 'Nystrom', 'O', 'O Hop-Toop', 'Oak', 'Oak', 'Oak', 'Oberg', 'Oberg', 'Oberon', 'Ocean Dock', 'Ocean Park', 'Ocean View', 'Ocean View', 'Oceanview', 'Okemo', 'Okemo', 'Old Cranberry', 'Old Dawson', 'Old Eagle River', 'Old Eagle River', 'Old Glenn', 'Old Harbor', 'Old Klatt', 'Old Rabbit Creek', 'Old Ridge', 'Old Seward', 'Oldford', 'Olson', 'OMalley Centre', 'OMalley Centre', 'Omega', 'Omega Mine', 'Ondola', 'Oneill', 'Oney', 'Opal', 'Opal', 'Opal', 'Orange Leaf', 'Orchard', 'Orchid', 'ORiedner', 'Oriole', 'Orion', 'Orth', 'Ostovia', 'Our Own', 'Outlook', 'Outlook', 'Overlake', 'Overlook', 'Overlook', 'Overlook', 'Overlook', 'Overlook', 'Overlook', 'Owen', 'Owen', 'Owhat', 'Owhat', 'Oxford', 'Pacific View', 'Pacific View', 'Pacific View', 'Packhorse', 'Paddock', 'Paine', 'Paine', 'Paine', 'Palmer', 'Palos Verdes', 'Panorama', 'Papa', 'Papa Bear', 'Papa Bear', 'Papa Bear', 'Paramount', 'Park', 'Park Hills', 'Park Hills', 'Park Hills', 'Park Hills', 'Park Place', 'Park Place', 'Park Place', 'Park West', 'Parker', 'Parker', 'Parks', 'Parsons', 'Passage', 'Patricia', 'Patriot', 'Patterson', 'Patterson', 'Patterson', 'Patterson', 'Paul Revere', 'Paula', 'Paula Sue', 'Paula Sue', 'Paula Sue', 'Peace', 'Peaceful Meadow', 'Peakview', 'Pearl', 'Pebblebrook', 'Pembroke', 'Penguin', 'Penguin', 'Peninsula', 'Peninsula', 'Penland', 'Penny', 'Penstemon', 'Peregrine', 'Peregrine', 'Perenosa', 'Peter S Ezi', 'Peter S Ezi', 'Peterkin', 'Peters Creek', 'Petes', 'Photo', 'Photo', 'Pickett', 'Pillow', 'Pine', 'Pine', 'Pine Ridge', 'Pintail', 'Pintail', 'Pioneer', 'Pioneer', 'Piper Trailer', 'Pitcairn', 'Platinum', 'Platinum', 'Platsek', 'Platsek', 'Pleasant View', 'Pleasant View', 'Plumas', 'Plumas', 'Plumas', 'Plumas', 'Point Woronzof', 'Point Woronzof', 'Pointe Resolution', 'Pokey', 'Pollock', 'Ponds', 'Ponds', 'Popcary', 'Poppy', 'Poppy', 'Port Access', 'Portage', 'Portage', 'Portage Glacier', 'Portage Glacier', 'Portage Lake', 'Portage Lake', 'Portugal', 'Portugal', 'Portugal', 'Portugal Place', 'Posiedon', 'Post', 'Postmark', 'Postmark', 'Potomac', 'Potomac', 'Potter Creek', 'Potter Crest', 'Potter Crest', 'Potter Valley', 'Powder Horn', 'Powder Ridge', 'Prator', 'Prator', 'Premier', 'Preuss', 'Preuss', 'Preuss', 'Primrose', 'Prism', 'Prospect', 'Prospect', 'Prospect', 'Prospect', 'Prosperity', 'Prosperity', 'Providence East', 'Prudhoe Bay', 'Ptarmigan', 'Ptarmigan', 'Ptarmigan', 'Ptarmigan Terrace', 'Puffin', 'Puffin Point', 'Puma', 'Purcell', 'Purlington', 'Purlington', 'Pussywillow', 'Pyramid', 'Queens', 'Queens View', 'Quest', 'Quick', 'Quinhagak', 'R', 'R', 'Rachael', 'Rachel', 'Rachel', 'Rainbow', 'Rainbow Valley', 'Rainy', 'Rakof', 'Rakof', 'Rambler', 'Ramona', 'Ramona', 'Rampart', 'Ranch', 'Rancho', 'Rand', 'Rand', 'Randamar', 'Randi', 'Randi', 'Rangeview', 'Rankin', 'Rankin', 'Rasmusson', 'Raspberry', 'Raven', 'Raven', 'Raven', 'Raven', 'Raven Crest', 'Raven Crest', 'Raven Loop', 'Raven Loop', 'Raven Roost', 'Ravenview Loop', 'Ray Halla', 'Raymar', 'Raymar', 'Raymond', 'Rebecca', 'Rebecca Hill', 'Rebel Ridge', 'Red Cedar', 'Red Currant', 'Red Currant', 'Red Currant', 'Red Leaf', 'Red Talon', 'Redhawk', 'Redpole', 'Redwood', 'Redwood', 'Redwood', 'Redwood', 'Redwood', 'Reed', 'Reflection', 'Refuge', 'Regal Mountain', 'Regal Mountain', 'Regal Mountain', 'Regency', 'Regency', 'Regent', 'Reliance', 'Renee', 'Resolution', 'Resolution', 'Resort', 'Resort', 'Resort', 'Retreat', 'Retreat', 'Revilla', 'Rezanof', 'Rhone', 'Richard Evelyn Byrd', 'Richard Evelyn Byrd', 'Richardson Frontage', 'Richardson Frontage', 'Richardson Vista', 'Richardson Vista', 'Richardson Vista', 'Ricky', 'Riddell', 'Riddell', 'Ridge', 'Ridge Park', 'Ridge Pointe', 'Ridge Top', 'Ridgecrest', 'Ridgeview', 'Rierie', 'Rierie', 'Ril', 'Rinner', 'Rio Grande', 'Rio Grande', 'Rita', 'River Heights', 'River Park', 'Rivers Edge', 'Riverton', 'Roads End', 'Roads End', 'Robert', 'Robert', 'Robin', 'Robin', 'Robinson', 'Robinson', 'Robinson', 'Rochelle', 'Rockwell', 'Rockwell', 'Rocky Mountain', 'Rodeo', 'Rodeo', 'Roe', 'Roe', 'Roehl', 'Roehl', 'Roehl', 'Roger', 'Roger Graves', 'Romania', 'Romania', 'Romig', 'Ronald', 'Ronald', 'Ronald', 'Roop', 'Roop', 'Rosalind', 'Rose', 'Rosebud', 'Rosebud', 'Rosehip Ridge', 'Rosehip Ridge', 'Rosella', 'Rosenburg', 'Roson', 'Rosser', 'Roundabout', 'Rovenna', 'Royal', 'Runners', 'Runners', 'Running Brook', 'Rushing River', 'Rushing River', 'Rusty Allen', 'Rusty Allen', 'Ruth', 'Ruth', 'Ruth', 'Ryan', 'Ryan', 'Ryoaks', 'S', 'Sabine', 'Saint Anton', 'Saint George', 'Saint Gotthard', 'Saint James', 'Saint Johann', 'Saint Lazaria', 'Salix', 'Samalga', 'San Clementson', 'San Ernesto', 'San Ernesto', 'San Ernesto', 'San Juan', 'Sanak', 'Sandpiper', 'Sandy', 'Sanford', 'Sarabelle', 'Sarah Barton', 'Savage', 'Savage', 'Savage', 'Savage', 'Scalero', 'Scenic', 'Scenic Hill', 'Scenic View', 'Scenic View', 'Scenic View', 'Schaff', 'Schodde', 'Schodde', 'Schoon', 'Schooner', 'Schulz', 'Schuss', 'Scoter', 'Scoter', 'Scott', 'Scott', 'Scott', 'Sea Parrott', 'Sea Parrott', 'Seacliff Terrace', 'Seacliff Terrace', 'Seacliff Terrace', 'Seacloud', 'Seaport', 'Seashore', 'Seashore', 'Seaview', 'Sebring', 'Seclusion Bay', 'Seclusion Bay', 'Second', 'Second', 'See Saw', 'Seika', 'Sentry', 'Sentry', 'Sentry', 'Service', 'Service', 'Service', 'Service', 'Service', 'Seville', 'Shadetree', 'Shadetree', 'Shadowy Spruce', 'Shady', 'Shady Bay', 'Shallow Pool', 'Shane', 'Sharon', 'Sharon Gagnon', 'Shelburne', 'Sheldon Jackson', 'Shelli', 'Shelly Marie', 'Shelter Rock', 'Sheltering Spruce', 'Sherwood', 'Ship', 'Shooresin', 'Shore', 'Shore', 'Shorecrest', 'Shorecrest', 'Shoshoni', 'Shoshoni', 'Shumagin', 'Shumagin', 'Shuttle', 'Silver Birch', 'Silver Fox', 'Silverado', 'Silvertip', 'Silverwood', 'Silverwood', 'Silverwood', 'Silverwood Hill', 'Silverwood Hill', 'Silvia', 'Sinner', 'Sitzmark', 'Sitzmark', 'Sitzmark', 'Skidmore', 'Skiff', 'Skipper', 'Sky Mountain', 'Sky Mountain', 'Skyhaven', 'Skyview', 'Slalom', 'Slana', 'Sleeping Lady', 'Sleepy', 'Small Boat Launch', 'Snow', 'Snow Goose', 'Snowdrift', 'Snowline', 'Snowmobile', 'Snowshoe', 'Snowy', 'Snug Harbor', 'Solitude', 'Sommers', 'Sommers', 'Songbird', 'Sonoma Crest', 'Sonoma Crest', 'Sonoma Crest', 'Sonoma Crest', 'Sorcerer', 'Sorrels', 'Sorrels', 'South Airpark', 'South Birchwood Loop', 'South Boundary', 'South Boundary', 'South Christmasberry', 'South Fork', 'South Gambell', 'South Juanita', 'South Mitkof', 'South Montague', 'South Park', 'South River', 'South River', 'South River', 'South River', 'South Salem', 'South Salem', 'South View', 'South Windsor', 'Southampton', 'Southcliff', 'Southeast Apron', 'Southpark', 'Southpark', 'Southport', 'Southport', 'Spain', 'Spalding', 'Spalding', 'Spalding', 'Sparkle', 'Sparks', 'Spartan', 'Specking', 'Spectrum', 'Spindrift', 'Spirit', 'Splendor', 'Sportsman', 'Sportsman', 'Spring', 'Spring', 'Spring Hill', 'Spring Hill', 'Springer', 'Sprint', 'Sproat', 'Spruce', 'Spruce', 'Spruce', 'Spruce Creek', 'Spruce Crest', 'Spruce Crest', 'Spruce Meadows', 'Spruce Meadows', 'Spruce Run', 'Sprucewood', 'Sprucewood', 'Spyglass', 'Spyglass Hill', 'Squaw Valley', 'Squire', 'Stacy', 'Staedem', 'Stamps', 'Stamps', 'Stamps', 'Standish', 'Stanford', 'Stanford', 'Stanford Drive', 'Stanford Drive', 'Stanton', 'Star', 'Star', 'Stargazer', 'Stargazer', 'Starlite', 'Starner', 'Staubbach', 'Steamboat', 'Steel', 'Steeple', 'Steeple', 'Steeple', 'Steffes', 'Steffes', 'Stelios', 'Stella', 'Stellar Jay', 'Steller', 'Stephan Valley', 'Stephandale', 'Stephanie', 'Stephen', 'Stepping Stone', 'Stevens Trailer', 'Stewart', 'Stewart', 'Stewart', 'Stewart Mountain', 'Stewart Mountain', 'Stockdale', 'Stockdale', 'Stoltze', 'Stonegate', 'Stonegate', 'Stonewood', 'Stormy', 'Stover', 'Stowe', 'Stowe', 'Stratford', 'Strathmore', 'Stratton', 'Strawberry Cottage', 'Strutz', 'Stuart', 'Stumpys', 'Sturbridge', 'Success', 'Sue Tawn', 'Sues', 'Sues', 'Sultana', 'Sumac', 'Summer', 'Summer', 'Summer', 'Summer Mist', 'Summerset', 'Sun Valley', 'Suncatcher', 'Suncrest', 'Suncrest', 'Suncrest', 'Sundew', 'Sundi', 'Sundi', 'Suneagle', 'Sunny', 'Sunnyside', 'Sunnyside', 'Sunset View', 'Sunshine', 'Sunstone', 'Sunstone', 'Sutwik', 'Swanee', 'Swanson', 'Sycamore', 'Sydney Park', 'Sydney Park', 'Sydnie Kay', 'Sydnie Kay', 'Taft', 'Tahoe', 'Tahoe', 'Taiga', 'Takotna', 'Talarik', 'Talarik', 'Talisman', 'Talisman', 'Tall Spruce', 'Talus', 'Tamarack', 'Tamarra', 'Tampa', 'Tamworth', 'Tamworth', 'Tana', 'Tana', 'Tanada', 'Tanada', 'Tanaga', 'Tangle', 'Tanglewood', 'Tasha', 'Tawni', 'Tawni', 'Tay', 'Tazlina', 'Teal', 'Telder', 'Telder', 'Telequana', 'Telequana', 'Telequana', 'Tempest', 'Temple', 'Tengberg', 'Teresa', 'Teri', 'Tern', 'Terrace', 'Terrace', 'Terrace', 'Terry', 'The Sun Loft', 'The Sun Loft', 'Theodore', 'Theodore', 'Theodore', 'Thiel', 'Third', 'Thompson', 'Thoreau', 'Thornton', 'Thornton', 'Thunder', 'Thunder Road Trailer Park', 'Thunderbird', 'Thunderbrush', 'Thurman', 'Ticia', 'Ticonderoga', 'Tidepool', 'Tideview', 'Tideview', 'Tidewater', 'Tidrington', 'Tiffany', 'Timber', 'Timber', 'Timberlane', 'Timberlane', 'Timothy', 'Timothy', 'Timothy', 'Tina', 'Toadstool', 'Toakee', 'Todd', 'Togiak', 'Toilsome Hill', 'Toilsome Hill', 'Toklat', 'Toklat', 'Tokositna', 'Tolhurst', 'Tolhurst', 'Tolsona', 'Tonsina', 'Tony', 'Topaz', 'Tophand Trailer', 'Town And Country', 'Town And Country', 'Toy', 'Toyon', 'Tracy', 'Trafford', 'Trafford', 'Trail', 'Trailhead', 'Trailhead', 'Trails End', 'Trails End Trailer', 'Trapline', 'Trapline', 'Trappers Trail', 'Traverse', 'Traverse', 'Treasure Box Mine', 'Tree Top', 'Trisha', 'Trotter', 'Trotter', 'Trudy', 'Trudy', 'Trudy', 'Tsusena', 'Tulane', 'Tulane', 'Tulin Park', 'Tulwar', 'Tundra Loop', 'Tundra Town Chalets Trailer', 'Tundra Town Chalets Trailer', 'Turnagain Bluff', 'Turnagain Bluff', 'Turnagain Bluff', 'Turnagain Boulevard', 'Twolots', 'Twolots', 'Tyls', 'Tyonek', 'Tyre', 'Tyre', 'U', 'Uaa', 'Umbarto Nobile', 'Unimak', 'Union', 'Union Square', 'Uno', 'Upper Canyon', 'Upper De Armoun', 'Upper Heritage', 'Upper Heritage', 'Upper Huffman', 'Upper Kogru', 'Upper Kogru', 'Upper Mc Crary', 'Ursa Minor', 'Vadla', 'Vail', 'Valarian', 'Valley', 'Valley', 'Valley Brook', 'Valley Forge', 'Valley Forge', 'Valley View', 'Vance', 'Vander', 'Vanderbilt', 'Vanderbilt', 'Vanderbilt', 'Vaquero', 'Vassar', 'Veco', 'Verdant', 'Verdant', 'Vern', 'Vernye', 'Victor', 'Victor', 'Victoria', 'Victoria', 'View', 'Viking', 'Village', 'Vincent', 'Vincent', 'Vintage', 'Viola', 'Violet', 'Violet', 'Violet', 'Virgin Creek', 'W', 'Wade', 'Wade', 'Wagon Wheel Trailer', 'Wagon Wheel Trailer', 'Wagon Wheel Trailer', 'Waiter', 'Waldron', 'Waldron', 'Wallace', 'Wallace', 'Wallace', 'Wallace', 'Wallace Wynd', 'Wallace Wynd', 'Wallace Wynd', 'Walls', 'Walrus', 'Walrus', 'Wandering', 'Wandering', 'Wanner', 'Wanner', 'Wanner', 'Wapiti', 'Ward', 'Warehouse', 'Warfield', 'Warning', 'Warwick', 'Warwick', 'Warwick', 'Washington', 'Waterfront', 'Waters', 'Waters', 'Waterwood', 'Waverly', 'Waverly', 'Waxwing', 'Waxwing', 'Weimer', 'Weimer', 'Wells', 'Wellsley', 'Wellsley', 'Wenmatt', 'Werre', 'Wes', 'West', 'West 100th', 'West 100th', 'West 10th', 'West 11th', 'West 121st', 'West 121st', 'West 123rd', 'West 123rd', 'West 13th', 'West 15th', 'West 15th', 'West 16th', 'West 17th', 'West 18th', 'West 18th', 'West 19th', 'West 21st', 'West 22nd', 'West 23rd', 'West 23rd', 'West 24th', 'West 24th', 'West 24th', 'West 24th', 'West 25th', 'West 27th', 'West 27th', 'West 29th', 'West 30th', 'West 31st', 'West 33rd', 'West 35th', 'West 36th', 'West 3rd', 'West 41st', 'West 42nd', 'West 43rd', 'West 44th', 'West 44th', 'West 46th', 'West 47th', 'West 51st', 'West 56th', 'West 57th', 'West 58th', 'West 58th', 'West 58th', 'West 5th', 'West 62nd', 'West 62nd', 'West 64th', 'West 65th', 'West 67th', 'West 69th', 'West 70th', 'West 71st', 'West 72nd', 'West 77th', 'West 77th', 'West 77th', 'West 78th', 'West 83rd', 'West 84th', 'West 86th', 'West 88th', 'West 88th', 'West 89th', 'West 8th', 'West 91st', 'West 91st', 'West 95th', 'West 99th', 'West Boundary', 'West Campus', 'West Cook', 'West Dimond', 'West Dowling', 'West Fireweed', 'West Franklin', 'West International Airport', 'West International Airport', 'West Kanaga', 'West Kanaga', 'West Kanaga', 'West Northern Lights', 'West Perimeter', 'West Ship Creek', 'West Zeus', 'West Zeus', 'West Zeus', 'Westa', 'Western', 'Westford', 'Westland', 'Westland', 'Westwind', 'Westwood', 'Whaler', 'Whaley', 'Whisper Knoll', 'Whispering Spruce', 'Whispering Spruce', 'Whisperwood Park', 'White Birch', 'White Hawk', 'White Hawk', 'White Spruce', 'Whitehall', 'Whitehall', 'Whiteney', 'Whitfield', 'Whittier Access', 'Whittier Access', 'Wickersham', 'Widgeon', 'Widgeon', 'Wilcox', 'Wilcox', 'Wild Mountain', 'Wild Rose', 'Wildberry', 'Wildbrook', 'Wildbrook', 'Wilderness', 'Wilderness', 'Wildflower', 'Wildien', 'Wildien', 'Wiley Post', 'Wiley Post', 'Wiley Post', 'Willene', 'William Jones', 'Willis', 'Williwa', 'Willow', 'Willson', 'Wilma', 'Wilma', 'Wilma', 'Wilson', 'Windham', 'Winding', 'Windlass', 'Windlass', 'Windlass', 'Windward', 'Windward', 'Wingham', 'Winston', 'Winter Park', 'Winter Park', 'Winter Ridge', 'Winterchase', 'Wintergreen', 'Wintergreen', 'Wintergreen', 'Wisconsin', 'Wisteria', 'Wisteria', 'Woburn', 'Woburn', 'Woburn', 'Wolcott', 'Wolf Creek', 'Wolf Creek', 'Wolf Creek', 'Wolf Creek', 'Woo', 'Wood River', 'Wood Spruce', 'Wood Spruce', 'Woodcliff', 'Woodcliff', 'Woodcliff', 'Woodcutter', 'Woodcutter', 'Wooded', 'Woodhaven', 'Woodhaven', 'Woodhaven', 'Woodland', 'Woodland Park', 'Woodland Park', 'Woodmont', 'Woodmont', 'Woodroe', 'Woodshire', 'Woodway', 'Woodway', 'Woster', 'Woster', 'Wrangell', 'Wrangell', 'Wrangell', 'Wren', 'Yakutat', 'Yale', 'Yarnot', 'Yarnot', 'Yellow Leaf', 'Yellow Leaf', 'Yorkshire', 'Young', 'Zircon', 'Zodiak', 'Zurich', 'Zurich');
declare variable $STREET-NAMES-COUNT := fn:count($STREET-NAMES);

declare variable $CITY-ZIPS :=
  xdmp:from-json-string('{"13125":"Manlius", "12166":"Sprakers", "14009":"Arcade", "13485":"West Edmeston", "12173":"Stuyvesant", "13835":"Richford", "13811":"Newark Valley", "13845":"Tioga Center", "13864":"Willseyville", "14850":"Ithaca", "14881":"Slaterville Springs", "13053":"Dryden", "14867":"Newfield", "12307":"Schenectady", "12053":"Delanson", "11738":"Farmingville", "11703":"North Babylon", "11955":"Moriches", "11718":"Brightwaters", "11364":"Oakland Gardens", "11381":"Flushing", "11106":"Astoria", "11422":"Rosedale", "13313":"Bridgewater", "13354":"Holland Patent", "13501":"Utica", "13157":"Sylvan Beach", "13473":"Turin", "13312":"Brantingham", "13433":"Port Leyden", "13648":"Harrisville", "14626":"Rochester", "14511":"Mumford", "12172":"Stottville", "12516":"Copake", "12513":"Claverack", "12530":"Hollowville", "12526":"Germantown", "12517":"Copake Falls", "12411":"Bloomington", "12409":"Bearsville", "12480":"Shandaken", "12782":"Sundown", "10536":"Katonah", "10603":"White Plains", "10533":"Irvington", "10590":"South Salem", "13060":"Elbridge", "13080":"Jordan", "13084":"La Fayette", "13208":"Syracuse", "11030":"Manhasset", "11793":"Wantagh", "11052":"Port Washington", "11570":"Rockville Centre", "14558":"South Lima", "14560":"Springwater", "14846":"Hunt", "13340":"Frankfort", "13431":"Poland", "13331":"Eagle Bay", "13329":"Dolgeville", "14464":"Hamlin", "14741":"Great Valley", "14060":"Farmersville Station", "14766":"Otto", "14070":"Gowanda", "14788":"Westons Mills", "14748":"Kill Buck", "11731":"East Northport", "11946":"Hampton Bays", "11739":"Great River", "11971":"Southold", "11790":"Stony Brook", "14830":"Corning", "14819":"Cameron", "14879":"Savona", "14706":"Allegany", "14729":"East Otto", "14753":"Limestone", "13762":"Endwell", "13790":"Johnson City", "13763":"Endicott", "13746":"Chenango Forks", "14586":"West Henrietta", "14445":"East Rochester", "11375":"Forest Hills", "14033":"Colden", "14269":"Buffalo", "14112":"North Evans", "14466":"Hemlock", "14480":"Lakeville", "14462":"Groveland", "13367":"Lowville", "13626":"Copenhagen", "13325":"Constableville", "13620":"Castorland", "14423":"Caledonia", "14435":"Conesus", "14485":"Lima", "10270":"New York", "14543":"Rush", "13063":"Fabius", "13152":"Skaneateles", "14787":"Westfield", "14750":"Lakewood", "14732":"Ellington", "14738":"Frewsburg", "14136":"Silver Creek", "14722":"Chautauqua", "12082":"Grafton", "12028":"Buskirk", "12185":"Valley Falls", "12094":"Johnsonville", "12747":"Hurleyville", "12784":"Thompsonville", "12748":"Jeffersonville", "12722":"Burlingham", "12738":"Glen Wild", "12765":"Neversink", "12745":"Hortonville", "12724":"Callicoon Center", "12769":"Phillipsport", "12789":"Woodridge", "11356":"College Point", "11780":"Saint James", "14925":"Elmira", "14838":"Erin", "14825":"Chemung", "14861":"Lowman", "14894":"Wellsburg", "10518":"Cross River", "14047":"Derby", "11044":"New Hyde Park", "14449":"East Williamson", "14519":"Ontario", "14589":"Williamson", "14433":"Clyde", "12989":"Vermontville", "12969":"Owls Head", "12917":"Burke", "12957":"Moira", "12976":"Rainbow Lake", "12983":"Saranac Lake", "12970":"Paul Smiths", "11565":"Malverne", "12985":"Schuyler Falls", "12929":"Dannemora", "12978":"Redford", "12952":"Lyon Mountain", "12979":"Rouses Point", "12972":"Peru", "12831":"Gansevoort", "12027":"Burnt Hills", "12151":"Round Lake", "12188":"Waterford", "12768":"Parksville", "13751":"Davenport Center", "13837":"Shinhopple", "13847":"Trout Creek", "13740":"Bovina Center", "13806":"Meridale", "13842":"South Kortright", "12841":"Huletts Landing", "12821":"Comstock", "12849":"Middle Granville", "12828":"Fort Edward", "12827":"Fort Ann", "13361":"Jordanville", "13491":"West Winfield", "10475":"Bronx", "11254":"Brooklyn", "13020":"Apulia Station", "13137":"Plainville", "11970":"South Jamesport", "11716":"Bohemia", "12853":"North Creek", "12808":"Adirondack", "12817":"Chestertown", "13672":"Parishville", "13678":"Raymondville", "12967":"North Lawrence", "13635":"Edwards", "12922":"Childwold", "13669":"Ogdensburg", "13630":"De Kalb Junction", "14888":"Valois", "12934":"Ellenburg Center", "13753":"Delhi", "13348":"Hartwick", "13482":"West Burlington", "12155":"Schenevus", "14717":"Caneadea", "14822":"Canaseraga", "14895":"Wellsville", "14880":"Scio", "14884":"Swain", "14739":"Friendship", "12484":"Stone Ridge", "12486":"Tillson", "12443":"Hurley", "12588":"Walker Valley", "12417":"Connelly", "11972":"Speonk", "12113":"Lawyersville", "14720":"Celoron", "13418":"North Brookfield", "13310":"Bouckville", "13465":"Solsville", "13032":"Canastota", "11431":"Jamaica", "12093":"Jefferson", "12043":"Cobleskill", "12175":"Summit", "12036":"Charlotteville", "10507":"Bedford Hills", "10547":"Mohegan Lake", "12052":"Cropseyville", "12033":"Castleton On Hudson", "12144":"Rensselaer", "13031":"Camillus", "12973":"Piercefield", "14420":"Brockport", "10509":"Brewster", "10512":"Carmel", "10516":"Cold Spring", "12837":"Hampton", "12848":"Middle Falls", "10969":"Pine Island", "10958":"New Hampton", "10996":"West Point", "12550":"Newburgh", "11855":"Hicksville", "11753":"Jericho", "11797":"Woodbury", "11569":"Point Lookout", "12843":"Johnsburg", "12860":"Pottersville", "14058":"Elba", "14525":"Pavilion", "14486":"Linwood", "14125":"Oakfield", "12790":"Wurtsboro", "14896":"West Danby", "10804":"Wykagyl", "12416":"Chichester", "12468":"Prattsville", "12058":"Earlton", "12482":"South Cairo", "12414":"Catskill", "12463":"Palenville", "12529":"Hillsdale", "12534":"Hudson", "12125":"New Lebanon", "13606":"Adams Center", "13675":"Plessis", "13692":"Thousand Island Park", "13659":"Lorraine", "14134":"Sardinia", "14067":"Gasport", "14108":"Newfane", "14302":"Niagara Falls", "13634":"Dexter", "12950":"Lewis", "12942":"Keene", "12960":"Moriah", "12592":"Wassaic", "12540":"Lagrangeville", "12537":"Hughsonville", "12538":"Hyde Park", "12564":"Pawling", "14541":"Romulus", "14860":"Lodi", "14847":"Interlaken", "14167":"Varysburg", "14145":"Strykersville", "14591":"Wyoming", "14530":"Perry", "14011":"Attica", "14592":"York", "14539":"Retsof", "13309":"Boonville", "13319":"Chadwicks", "11413":"Springfield Gardens", "11426":"Bellerose", "13655":"Hogansburg", "12232":"Albany", "11554":"East Meadow", "11773":"Syosset", "11576":"Roslyn", "14823":"Canisteo", "14821":"Campbell", "14572":"Wayland", "12915":"Brainardsville", "11429":"Queens Village", "14871":"Pine City", "14505":"Marion", "14513":"Newark", "12863":"Rock City Falls", "12833":"Greenfield Center", "12170":"Stillwater", "13341":"Franklin Springs", "13775":"Franklin", "13813":"Nineveh", "13862":"Whitney Point", "12089":"Hoosick", "12040":"Cherry Plain", "13476":"Vernon", "14085":"Lake View", "10537":"Lake Peekskill", "10542":"Mahopac Falls", "12563":"Patterson", "13859":"Wells Bridge", "14442":"Eagle Harbor", "14777":"Rushford", "11705":"Bayport", "11959":"Quogue", "12804":"Queensbury", "12874":"Silver Bay", "12845":"Lake George", "12439":"Hensonville", "12083":"Greenville", "12060":"East Chatham", "14475":"Ionia", "14461":"Gorham", "14471":"Honeoye", "10580":"Rye", "10576":"Pound Ridge", "13420":"Old Forge", "12441":"Highmount", "12515":"Clintondale", "11940":"East Moriches", "11747":"Melville", "11730":"East Islip", "11976":"Water Mill", "11930":"Amagansett", "14150":"Tonawanda", "13334":"Eaton", "13035":"Cazenovia", "11559":"Lawrence", "14048":"Dunkirk", "12162":"South Schodack", "12179":"Troy", "11968":"Southampton", "14758":"Niobe", "14719":"Cattaraugus", "14751":"Leon", "10914":"Blooming Grove", "12566":"Pine Bush", "12780":"Sparrow Bush", "13026":"Aurora", "13024":"Auburn", "13156":"Sterling", "13081":"King Ferry", "13118":"Moravia", "11766":"Mount Sinai", "13627":"Deer River", "13848":"Tunnel", "12946":"Lake Placid", "12961":"Moriah Center", "13136":"Pitcher", "13758":"East Pharsalia", "13778":"Greene", "13801":"Mc Donough", "13332":"Earlville", "13129":"Georgetown", "12577":"Salisbury Mills", "14836":"Dalton", "10913":"Blauvelt", "10960":"Nyack", "10931":"Hillburn", "13052":"De Ruyter", "13314":"Brookfield", "14065":"Freedom", "12428":"Ellenville", "11741":"Holbrook", "13078":"Jamesville", "10983":"Tappan", "10980":"Stony Point", "10974":"Sloatsburg", "13439":"Richfield Springs", "13335":"Edmeston", "13861":"West Oneonta", "12504":"Annandale On Hudson", "12590":"Wappingers Falls", "12546":"Millerton", "12603":"Poughkeepsie", "12725":"Claryville", "14726":"Conewango Valley", "14724":"Clymer", "14752":"Lily Dale", "11378":"Maspeth", "11377":"Woodside", "13631":"Denmark", "13305":"Beaver Falls", "10918":"Chester", "12809":"Argyle", "12839":"Hudson Falls", "12095":"Johnstown", "12025":"Broadalbin", "13470":"Stratford", "12117":"Mayfield", "14775":"Ripley", "14081":"Irving", "10920":"Congers", "10989":"Valley Cottage", "10965":"Pearl River", "10956":"New City", "10970":"Pomona", "10995":"West Nyack", "14715":"Bolivar", "13865":"Windsor", "12198":"Wynantskill", "12153":"Sand Lake", "12786":"White Lake", "13401":"Mc Connellsville", "13318":"Cassville", "12823":"Cossayuna", "12156":"Schodack Landing", "13472":"Thendara", "14120":"North Tonawanda", "14126":"Olcott", "14174":"Youngstown", "14092":"Lewiston", "14897":"Whitesville", "11941":"Eastport", "11582":"Valley Stream", "12578":"Salt Point", "11760":"Hauppauge", "12130":"Niverville", "12565":"Philmont", "12174":"Stuyvesant Falls", "14872":"Pine Valley", "13041":"Clay", "13143":"Red Creek", "14590":"Wolcott", "13154":"South Butler", "14555":"Sodus Point", "14546":"Scottsville", "14859":"Lockwood", "13827":"Owego", "14883":"Spencer", "12514":"Clinton Corners", "12959":"Mooers Forks", "12933":"Ellenburg", "12962":"Morrisonville", "14891":"Watkins Glen", "14841":"Hector", "14812":"Beaver Dams", "11566":"Merrick", "11804":"Old Bethpage", "13407":"Mohawk", "12474":"Roxbury", "12074":"Galway", "14522":"Palmyra", "12176":"Surprise", "12424":"East Jewett", "12760":"Long Eddy", "14075":"Hamburg", "12826":"East Greenwich", "11507":"Albertson", "11561":"Long Beach", "10941":"Middletown", "11931":"Aquebogue", "11708":"Amityville", "11363":"Little Neck", "11414":"Howard Beach", "10521":"Croton On Hudson", "14744":"Houghton", "14774":"Richburg", "12838":"Hartford", "12816":"Cambridge", "12057":"Eagle Bridge", "12787":"White Sulphur Springs", "12743":"Highland Lake", "12785":"Westbrookville", "13489":"West Leyden", "11696":"Inwood", "12501":"Amenia", "12531":"Holmes", "10975":"Southfields", "12739":"Godeffroy", "12469":"Preston Hollow", "14874":"Pulteney", "14855":"Jasper", "14827":"Coopers Plains", "14843":"Hornell", "11798":"Wyandanch", "14809":"Avoca", "11778":"Rocky Point", "12032":"Caroga Lake", "13623":"Chippewa Bay", "13670":"Oswegatchie", "12857":"Olmstedville", "13076":"Hastings", "13493":"Williamstown", "13145":"Sandy Creek", "13074":"Hannibal", "12106":"Kinderhook", "14723":"Cherry Creek", "12740":"Grahamsville", "13484":"West Eaton", "13061":"Erieville", "14488":"Livonia Center", "10519":"Croton Falls", "10553":"Mount Vernon", "11740":"Greenlawn", "11786":"Shoreham", "14080":"Holland", "14031":"Clarence", "13050":"Cuyler", "11588":"Uniondale", "14032":"Clarence Center", "13428":"Palatine Bridge", "12072":"Fultonville", "12070":"Fort Johnson", "12016":"Auriesville", "12069":"Fort Hunter", "12912":"Au Sable Forks", "12958":"Mooers", "14504":"Manchester", "12071":"Fultonham", "14515":"North Greece", "12586":"Walden", "14143":"Stafford", "14013":"Basom", "12493":"West Park", "13660":"Madrid", "12781":"Summitville", "12120":"Medusa", "12107":"Knox", "13461":"Sherrill", "13442":"Rome", "13323":"Clinton", "13338":"Forestport", "13162":"Verona Beach", "12986":"Tupper Lake", "12937":"Fort Covington", "12141":"Quaker Street", "12150":"Rotterdam Junction", "12553":"New Windsor", "10538":"Larchmont", "14801":"Addison", "14858":"Lindley", "13321":"Clark Mills", "14132":"Sanborn", "14109":"Niagara University", "14870":"Painted Post", "14171":"West Valley", "14778":"Saint Bonaventure", "12067":"Feura Bush", "12007":"Alcove", "13743":"Candor", "10923":"Garnerville", "14863":"Mecklenburg", "14887":"Tyrone", "13622":"Chaumont", "10305":"Staten Island", "12465":"Pine Hill", "12440":"High Falls", "14428":"Churchville", "14039":"Dale", "14024":"Bliss", "13027":"Baldwinsville", "10911":"Bear Mountain", "11977":"Westhampton", "12520":"Cornwall On Hudson", "11419":"South Richmond Hill", "14556":"Sonyea", "13092":"Locke", "14839":"Greenwood", "14138":"South Dayton", "14760":"Olean", "11104":"Sunnyside", "13342":"Garrattsville", "13810":"Mount Vision", "14453":"Fishers", "14463":"Hall", "12974":"Port Henry", "12459":"New Kingston", "13315":"Burlington Flats", "12412":"Boiceville", "13804":"Masonville", "13450":"Roseboom", "13488":"Westford", "11963":"Sag Harbor", "14036":"Corfu", "14416":"Bergen", "14054":"East Bethany", "12020":"Ballston Spa", "12835":"Hadley", "12850":"Middle Grove", "12776":"Roscoe", "10952":"Monsey", "11411":"Cambria Heights", "12124":"New Baltimore", "12452":"Lexington", "12051":"Coxsackie", "12764":"Narrowsburg", "13410":"Nelliston", "12522":"Dover Plains", "13133":"Chittenango", "14043":"Depew", "14733":"Falconer", "14456":"Geneva", "10959":"New Milford", "13901":"Binghamton", "14168":"Versailles", "12123":"Nassau", "10572":"Pleasantville", "12075":"Ghent", "13682":"Rodman", "13674":"Pierrepont Manor", "11709":"Bayville", "13042":"Cleveland", "13131":"Parish", "12583":"Tivoli", "12506":"Bangall", "13834":"Portlandville", "13343":"Glenfield", "12746":"Huguenot", "13688":"South Rutland", "13607":"Alexandria Bay", "10922":"Fort Montgomery", "13486":"Westernville", "14561":"Stanley", "14469":"Bloomfield", "14432":"Clifton Springs", "14532":"Phelps", "12423":"East Durham", "00501":"Holtsville", "10928":"Highland Falls", "10953":"Mountainville", "12803":"South Glens Falls", "11962":"Sagaponack", "13455":"Sangerfield", "13147":"Scipio Center", "10954":"Nanuet", "12066":"Esperance", "12068":"Fonda", "13464":"Smyrna", "10973":"Slate Hill", "14716":"Brocton", "12446":"Kerhonkson", "12548":"Modena", "13739":"Bloomville", "12455":"Margaretville", "12435":"Greenfield Park", "12481":"Shokan", "12078":"Gloversville", "13860":"West Davenport", "11803":"Plainview", "13830":"Oxford", "12464":"Phoenicia", "13479":"Washington Mills", "12996":"Willsboro", "13316":"Camden", "13490":"Westmoreland", "13029":"Brewerton", "13434":"Pratts Hollow", "13621":"Chase Mills", "12111":"Latham", "13102":"Mc Lean", "14817":"Brooktondale", "10579":"Putnam Valley", "11590":"Westbury", "10925":"Greenwood Lake", "12924":"Keeseville", "13339":"Fort Plain", "14730":"East Randolph", "11751":"Islip", "11359":"Bayside", "13654":"Heuvelton", "10541":"Mahopac", "12438":"Halcottsville", "12430":"Fleischmanns", "14826":"Cohocton", "12062":"East Nassau", "13615":"Brownville", "13612":"Black River", "13336":"Middleville", "12913":"Bloomingdale", "14805":"Alpine", "14869":"Odessa", "12939":"Gabriels", "13797":"Lisle", "14534":"Pittsford", "12154":"Schaghticoke", "14056":"East Pembroke", "13747":"Colliersville", "13808":"Morris", "11697":"Breezy Point", "11518":"East Rockaway", "12046":"Coeymans Hollow", "14091":"Lawtons", "12766":"North Branch", "11944":"Greenport", "14529":"Perkinsville", "13750":"Davenport", "12055":"Dormansville", "12719":"Barryville", "11754":"Kings Park", "14550":"Silver Springs", "14472":"Honeoye Falls", "13782":"Hamden", "11535":"Garden City", "11736":"Farmingdale", "14526":"Penfield", "14482":"Le Roy", "14006":"Angola", "13139":"Poplar Ridge", "13605":"Adams", "13158":"Truxton", "13738":"Blodgett Mills", "13087":"Little York", "13784":"Harford", "11710":"Bellmore", "11805":"Mid Island", "14721":"Ceres", "14714":"Black Creek", "14776":"Rossburg", "12132":"North Chatham", "11707":"West Babylon", "14041":"Dayton", "14728":"Dewittville", "14487":"Livonia", "10510":"Briarcliff Manor", "10976":"Sparkill", "11975":"Wainscott", "11752":"Islip Terrace", "13680":"Rensselaer Falls", "11415":"Kew Gardens", "10589":"Somers", "14551":"Sodus", "14542":"Rose", "14489":"Lyons", "12832":"Granville", "14095":"Lockport", "12777":"Forestburgh", "11596":"Williston Park", "12489":"Wawarsing", "13601":"Watertown", "13466":"South Edmeston", "12543":"Maybrook", "11575":"Roosevelt", "12406":"Arkville", "10540":"Lincolndale", "14166":"Van Buren Point", "13117":"Montezuma", "12498":"Woodstock", "12528":"Highland", "12419":"Cottekill", "13036":"Central Square", "11002":"Floral Park", "11549":"Hempstead", "11598":"Woodmere", "14557":"South Byron", "14021":"Batavia", "13144":"Richland", "11939":"East Marion", "14536":"Portageville", "12956":"Mineville", "12994":"Whallonsburg", "13602":"Fort Drum", "14588":"Willard", "13065":"Fayette", "13815":"Norwich", "11767":"Nesconset", "14845":"Horseheads", "11953":"Middle Island", "14886":"Trumansburg", "13073":"Groton", "13749":"Corbettsville", "12943":"Keene Valley", "12941":"Jay", "12879":"Newcomb", "13164":"Warners", "10707":"Tuckahoe", "13055":"East Freetown", "14731":"Ellicottville", "13308":"Blossvale", "11935":"Cutchogue", "12189":"Watervliet", "13803":"Marathon", "13141":"Preble", "14538":"Pultneyville", "14898":"Woodhull", "13425":"Oriskany Falls", "12742":"Harris", "12727":"Cochecton Center", "11960":"Remsenburg", "14038":"Crittenden", "12998":"Witherbee", "12870":"Schroon Lake", "13665":"Natural Bridge", "12916":"Brushton", "14756":"Maple Springs", "13468":"Springfield Center", "13337":"Fly Creek", "12883":"Ticonderoga", "11762":"Massapequa Park", "13647":"Hannawa Falls", "13667":"Norfolk", "12472":"Rosendale", "12872":"Severance", "13322":"Clayville", "14098":"Lyndonville", "14470":"Holley", "14477":"Kent", "14476":"Kendall", "12920":"Chateaugay", "14708":"Alma", "13355":"Hubbardsville", "13820":"Oneonta", "11771":"Oyster Bay", "10949":"Monroe", "13044":"Constantia", "12858":"Paradox", "12752":"Lake Huntington", "14506":"Mendon", "13614":"Brier Hill", "10505":"Baldwin Place", "13628":"Deferiet", "12059":"East Berne", "11423":"Hollis", "13608":"Antwerp", "13618":"Cape Vincent", "13040":"Cincinnatus", "12779":"South Fallsburg", "12734":"Ferndale", "14037":"Cowlesville", "13368":"Lyons Falls", "14140":"Spring Brook", "14055":"East Concord", "12460":"Oak Hill", "12436":"Haines Falls", "10597":"Waccabuc", "10577":"Purchase", "13795":"Kirkwood", "10535":"Jefferson Valley", "10596":"Verplanck", "10549":"Mount Kisco", "12121":"Melrose", "12935":"Ellenburg Depot", "12720":"Bethel", "12195":"West Lebanon", "12521":"Craryville", "12575":"Rock Tavern", "12555":"Mid Hudson", "11516":"Cedarhurst", "12161":"South Bethlehem", "12561":"New Paltz", "13116":"Minoa", "12541":"Livingston", "12017":"Austerlitz", "12491":"West Hurley", "12108":"Lake Pleasant", "12190":"Wells", "12139":"Piseco", "12754":"Liberty", "12758":"Livingston Manor", "12762":"Mongaup Valley", "14113":"North Java", "11501":"Mineola", "12866":"Saratoga Springs", "14072":"Grand Island", "13077":"Homer", "13863":"Willet", "14824":"Cayuta", "14427":"Castile", "12919":"Champlain", "12910":"Altona", "14742":"Greenhurst", "13730":"Afton", "12545":"Millbrook", "13619":"Carthage", "12968":"Onchiota", "13825":"Otego", "14865":"Montour Falls", "14818":"Burdett", "10916":"Campbell Hall", "11109":"Long Island City", "11792":"Wading River", "14424":"Canandaigua", "11776":"Port Jefferson Station", "12137":"Pattersonville", "12819":"Clemons", "11732":"East Norwich", "12420":"Cragsmoor", "12854":"North Granville", "13101":"Mc Graw", "14172":"Wilson", "12454":"Maplecrest", "12431":"Freehold", "13130":"Owasco", "11715":"Blue Point", "14527":"Penn Yan", "14418":"Branchport", "14712":"Bemus Point", "10990":"Warwick", "13043":"Clockville", "10979":"Sterling Forest", "13844":"South Plymouth", "13124":"North Pitcher", "14413":"Alton", "10803":"Pelham", "12050":"Columbiaville", "11745":"Smithtown", "11967":"Shirley", "12820":"Cleverdale", "12801":"Glens Falls", "13350":"Herkimer", "10977":"Spring Valley", "13134":"Peterboro", "13421":"Oneida", "12483":"Spring Glen", "14082":"Java Center", "14569":"Warsaw", "13697":"Winthrop", "13652":"Hermon", "12495":"Willow", "12432":"Glasco", "14005":"Alexander", "14040":"Darien Center", "14102":"Marilla", "13777":"Glen Aubrey", "12087":"Hannacroix", "12405":"Acra", "14584":"Webster Crossing", "13122":"New Woodstock", "12494":"West Shokan", "13346":"Hamilton", "12542":"Marlboro", "12118":"Mechanicville", "13783":"Hancock", "13477":"Vernon Center", "13056":"East Homer", "14877":"Rexville", "13638":"Felts Mills", "13812":"Nichols", "12949":"Lawrenceville", "11027":"Great Neck", "13677":"Pyrites", "13662":"Massena", "13362":"Knoxboro", "10926":"Harriman", "12063":"East Schodack", "14467":"Henrietta", "12810":"Athol", "14083":"Java Village", "13640":"Wellesley Island", "13693":"Three Mile Bay", "12570":"Poughquag", "13146":"Savannah", "13039":"Cicero", "12873":"Shushan", "14517":"Nunda", "14414":"Avon", "10912":"Bellvale", "11560":"Locust Valley", "13698":"Woodville", "12923":"Churubusco", "14086":"Lancaster", "10587":"Shenorock", "13352":"Hinckley", "13303":"Ava", "11722":"Central Islip", "14893":"Wayne", "13328":"Deansboro", "13415":"New Lisbon", "12064":"East Worcester", "14518":"Oaks Corners", "10706":"Hastings On Hudson", "12589":"Wallkill", "12878":"Stony Creek", "11416":"Ozone Park", "14051":"East Amherst", "13661":"Mannsville", "12434":"Grand Gorge", "14103":"Medina", "14429":"Clarendon", "13437":"Redfield", "13699":"Potsdam", "11757":"Lindenhurst", "14745":"Hume", "13435":"Prospect", "14873":"Prattsburgh", "11947":"Jamesport", "12167":"Stamford", "13107":"Maple View", "14520":"Ontario Center", "12997":"Wilmington", "13851":"Vestal", "10710":"Yonkers", "12886":"Wevertown", "13471":"Taberg", "13345":"Greig", "11418":"Richmond Hill", "13424":"Oriskany", "11733":"East Setauket", "14889":"Van Etten", "10992":"Washingtonville", "13456":"Sauquoit", "13034":"Cayuga", "13752":"De Lancey", "12037":"Chatham", "12584":"Vails Gate", "12733":"Fallsburg", "11369":"East Elmhurst", "11933":"Calverton", "14170":"West Falls", "14864":"Millport", "13045":"Cortland", "12487":"Ulster Park", "12966":"North Bangor", "13733":"Bainbridge", "12812":"Blue Mountain Lake", "13068":"Freeville", "12995":"Whippleville", "12992":"West Chazy", "13649":"Helena", "14737":"Franklinville", "13452":"Saint Johnsville", "12086":"Hagaman", "14549":"Silver Lake", "14749":"Knapp Creek", "11558":"Island Park", "14710":"Ashville", "12092":"Howes Cave", "12073":"Gallupville", "12131":"North Blenheim", "14740":"Gerry", "12864":"Sabael", "12842":"Indian Lake", "12023":"Berne", "12778":"Smallwood", "13419":"North Western", "12945":"Lake Clear", "13756":"East Branch", "14837":"Dundee", "14441":"Dresden", "12580":"Staatsburg", "13085":"Lebanon", "12008":"Alplaus", "13317":"Canajoharie", "14810":"Bath", "10528":"Harrison", "12456":"Mount Marion", "12159":"Slingerlands", "12822":"Corinth", "14105":"Middleport", "14028":"Burt", "12186":"Voorheesville", "14139":"South Wales", "11695":"Far Rockaway", "12042":"Climax", "10526":"Goldens Bridge", "13111":"Martville", "13071":"Genoa", "11758":"Massapequa", "10545":"Maryknoll", "12457":"Mount Tremper", "13163":"Wampsville", "13780":"Guilford", "14813":"Belmont", "13839":"Sidney Center", "12084":"Guilderland", "12148":"Rexford", "10901":"Suffern", "14783":"Steamburg", "14559":"Spencerport", "12930":"Dickinson Center", "12753":"Lew Beach", "12085":"Guilderland Center", "12737":"Glen Spey", "12090":"Hoosick Falls", "14815":"Bradford", "14802":"Alfred", "14786":"West Clarksville", "12115":"Malden Bridge", "11932":"Bridgehampton", "13684":"Russell", "12024":"Brainard", "12466":"Port Ewen", "11795":"West Islip", "14110":"North Boston", "13833":"Port Crane", "12444":"Jewett", "12422":"Durham", "11980":"Yaphank", "13089":"Liverpool", "13057":"East Syracuse", "12987":"Upper Jay", "13153":"Skaneateles Falls", "11694":"Rockaway Park", "13641":"Fishers Landing", "10988":"Unionville", "14709":"Angelica", "14804":"Almond", "14508":"Morton", "13832":"Plymouth", "14107":"Model City", "11725":"Commack", "11510":"Baldwin", "14703":"Jamestown", "13327":"Croghan", "12477":"Saugerties", "10502":"Ardsley", "10709":"Eastchester", "13691":"Theresa", "11973":"Upton", "12783":"Swan Lake", "13417":"New York Mills", "12442":"Hunter", "13650":"Henderson", "13492":"Whitesboro", "14035":"Collins Center", "12751":"Kiamesha Lake", "13115":"Minetto", "11743":"Huntington", "13744":"Castle Creek", "14857":"Lakemont", "14544":"Rushville", "14478":"Keuka Park", "14757":"Mayville", "12927":"Cranberry Lake", "13754":"Deposit", "13679":"Redwood", "13411":"New Berlin", "12533":"Hopewell Junction", "12572":"Rhinebeck", "13616":"Calcium", "11552":"West Hempstead", "10591":"Tarrytown", "11702":"Babylon", "11568":"Old Westbury", "14516":"North Rose", "14452":"Fancher", "13809":"Mount Upton", "14415":"Bellona", "11714":"Bethpage", "14807":"Arkport", "14068":"Getzville", "13755":"Downsville", "12524":"Fishkill", "11727":"Coram", "13404":"Martinsburg", "13695":"Wanakena", "13353":"Hoffmeister", "11726":"Copiague", "12932":"Elizabethtown", "14808":"Atlanta", "10517":"Crompond", "14885":"Troupsburg", "10930":"Highland Mills", "13846":"Treadwell", "12054":"Delmar", "11901":"Riverhead", "13054":"Durhamville", "12076":"Gilboa", "12031":"Carlisle", "11782":"Sayville", "14410":"Adams Basin", "14882":"Lansing", "12401":"Kingston", "13841":"Smithville Flats", "11509":"Atlantic Beach", "13365":"Little Falls", "13656":"La Fargeville", "13438":"Remsen", "11420":"South Ozone Park", "13360":"Inlet", "12847":"Long Lake", "10932":"Howells", "11547":"Glenwood Landing", "11374":"Rego Park", "14502":"Macedon", "14411":"Albion", "14479":"Knowlesville", "13480":"Waterville", "12177":"Tribes Hill", "12507":"Barrytown", "11789":"Sound Beach", "14878":"Rock Stream", "13856":"Walton", "13083":"Lacona", "13028":"Bernhards Bay", "12981":"Saranac", "11937":"East Hampton", "14443":"East Bloomfield", "11765":"Mill Neck", "11385":"Ridgewood", "11004":"Glen Oaks", "12168":"Stephentown", "12914":"Bombay", "14131":"Ransomville", "13066":"Fayetteville", "14772":"Randolph", "13324":"Cold Brook", "10964":"Palisades", "10987":"Tuxedo Park", "13460":"Sherburne", "14030":"Chaffee", "10560":"North Salem", "10604":"West Harrison", "12450":"Lanesville", "12492":"West Kill", "10532":"Hawthorne", "14806":"Andover", "13690":"Star Lake", "13666":"Newton Falls", "12523":"Elizaville", "11692":"Arverne", "12511":"Castle Point", "12134":"Northville", "12116":"Maryland", "11749":"Islandia", "13155":"South Otselic", "12160":"Sloansville", "13840":"Smithboro", "12449":"Lake Katrine", "14004":"Alden", "14034":"Collins", "10998":"Westtown", "13138":"Pompey", "12723":"Callicoon", "14533":"Piffard", "14063":"Fredonia", "13757":"East Meredith", "14521":"Ovid", "12461":"Olivebridge", "13494":"Woodgate", "13774":"Fishs Eddy", "12404":"Accord", "14069":"Glenwood", "11579":"Sea Cliff", "14144":"Stella Niagara", "13150":"Sennett", "12771":"Port Jervis", "13478":"Verona", "12993":"Westport", "13838":"Sidney", "14510":"Mount Morris", "10503":"Ardsley On Hudson", "13826":"Ouaquaga", "13745":"Chenango Bridge", "10524":"Garrison", "11958":"Peconic", "11357":"Whitestone", "10951":"Rockland M P C", "14135":"Sheridan", "10523":"Elmsford", "13062":"Etna", "11412":"Saint Albans", "14892":"Waverly", "12921":"Chazy", "13776":"Gilbertsville", "12775":"Rock Hill", "13126":"Oswego", "13114":"Mexico", "14012":"Barker", "13408":"Morrisville", "12470":"Purling"}');
declare variable $CITY-ZIPS-COUNT := map:count($CITY-ZIPS);

declare variable $ZIP-COUNT :=
  let $codes := xdmp:get-server-field("zip-codes-count")
  return
    if (fn:exists($codes)) then $codes
    else
      xdmp:set-server-field("zip-codes-count", xdmp:estimate(/zip-geo:zip_geo));

declare variable $MARITAL-STATUSES := ('Never Married', 'Legally Separated', 'Divorced', 'Widowed');
declare variable $MARITAL-STATUSES-COUNT := fn:count($MARITAL-STATUSES);

declare function trns:get-ssn($id as xs:string)
{
  fn:replace(fn:string(xdmp:hash32($id)), "(\d\d\d)(\d\d)(\d\d\d\d).*", "$1-$2-$3")
};

declare function trns:parse-date($date as xs:string)
{
  if (fn:matches($date, "(\d\d)/(\d\d)/(\d\d\d\d)")) then
    fn:replace($date, "(\d\d)/(\d\d)/(\d\d\d\d)", "$3-$1-$2")
  else if (fn:matches($date, "(\d\d\d\d)(\d\d)(\d\d)")) then
    fn:replace($date, "(\d\d\d\d)(\d\d)(\d\d)", "$1-$2-$3")
  else ()
};

declare function trns:random-name($names)
{
  if (fn:exists($names)) then
    trns:random-name($names, fn:count($names))
  else ()
};

declare function trns:random-name($names, $count)
{
  let $rnd := xdmp:random($count - 1) + 1
  return
    $names[$rnd]
};

declare function trns:get-random-phone()
{
  fn:string-join((
    "tel:+1",
    (xdmp:random(899) + 100) ! fn:string(),
    (xdmp:random(899) + 100) ! fn:string(),
    (xdmp:random(8999) + 1000) ! fn:string()
  ), "-")
};

declare function trns:get-random-address()
{
  fn:string-join((
    fn:string(xdmp:random(99999) + 1),
    trns:random-name($STREET-NAMES, $STREET-NAMES-COUNT),
    trns:random-name($ROAD-TYPES, $ROAD-TYPES-COUNT)
  ),
  " ")
};

declare function trns:get-npis-from-zip($zip as xs:string)
{
  let $point := /zip-geo:zip_geo[zip-geo:postal = $zip]/cts:point(zip-geo:latitude, zip-geo:longitude)
  where fn:exists($point)
  return
    trns:get-npis-from-point($point)
};

declare function trns:get-npis-from-point($point as cts:point)
{
  trns:get-npis-from-point($point, ())
};

declare function trns:get-npis-from-point($point as cts:point, $query as cts:query?)
{
  (
    let $map := cts:value-co-occurrences(
      cts:element-reference(xs:QName("cms:npi"),("collation=http://marklogic.com/collation/codepoint")),
      cts:geospatial-attribute-pair-reference(xs:QName("cms:address"), xs:QName("lat"), xs:QName("lng")),
      ("map", "limit=100"),
      cts:and-query((
        $query,
        cts:element-attribute-pair-geospatial-query(
          xs:QName("cms:address"),
          xs:QName("lat"),
          xs:QName("lng"),
          cts:circle(50, $point))
      )))
    for $key in map:keys($map)
    let $value := map:get($map, $key)
    let $dist := cts:distance($value[1], $point)
    order by $dist ascending
    return
      $key
  )[1]
};

declare function trns:normalize-ndc($ndc as xs:string) as xs:string+
{
  let $normalized-ndc := fn:substring($ndc, 1, 9)
  return
  (
    $ndc, $normalized-ndc, fn:replace($normalized-ndc, "(\d{5})0(\d{3})", "$1*$2")
  )
};

declare function trns:_get-drug-name-from-ndc-sparql($ndcs as xs:string*) as xs:string?
{
  let $ndc := $ndcs[1]
  where $ndc
  return
    let $name :=
      let $m := sem:sparql-values(
        'prefix skos: <http://www.w3.org/2004/02/skos/core#>
         prefix nddf: <http://purl.bioontology.org/ontology/NDDF/>
         prefix rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
         SELECT ?label
         WHERE {
          ?subj skos:prefLabel ?label .
          { ?subj nddf:NDC ?ndc }
          UNION
          { ?subj rxnorm:NDC ?ndc }
        }',
        map:new(map:entry('ndc', $ndc)))
      return
        map:get($m, "label")[1]
    return
      if (fn:exists($name)) then $name
      else
        trns:_get-drug-name-from-ndc-sparql(fn:subsequence($ndcs, 2))
};

declare function trns:_get-drug-name-from-ndc($ndcs as xs:string*) as xs:string?
{
  let $ndc := $ndcs[1]
  where $ndc
  return
    let $name :=
      let $old-ndc := map:get($codes:OLD-NDC-CODES, $ndc)
      return
        if (fn:exists($old-ndc)) then $old-ndc
        else
          map:get($codes:NEW-NDC-CODES, $ndc)
    return
      if (fn:exists($name)) then $name
      else
        trns:_get-drug-name-from-ndc(fn:subsequence($ndcs, 2))
};

declare function trns:get-drug-name-from-ndc($ndc as xs:string) as xs:string?
{
  let $ndcs := trns:normalize-ndc($ndc)
  let $quick-name := trns:_get-drug-name-from-ndc($ndcs)
  return
    if (fn:exists($quick-name)) then $quick-name
    else
      trns:_get-drug-name-from-ndc-sparql($ndcs)
};

declare function trns:get-npis-from-cpt(
  $cpt as xs:string*,
  $point as cts:point) as xs:string*
{
  trns:get-npis-from-point($point, cts:element-value-query(xs:QName("cms:cpt-code"), $cpt, ("exact")))
};

declare function trns:get-npis-from-icd9($icd9 as xs:string)
{
  (: paxton todo: make this work :)
  cts:element-values(xs:QName("cms:npi"), (), ("limit=25", "collation=http://marklogic.com/collation/codepoint"))
};

declare function trns:get-random-zip()
{
  fn:doc(
    trns:random-name(
      cts:uris((), (), cts:collection-query("postal")), $ZIP-COUNT))/zip-geo:zip_geo
};

declare function trns:get-random-city-state-zip()
{
  let $zip-info := trns:get-random-zip()
  let $zip as xs:string? := $zip-info/zip-geo:postal[. ne '']
  let $city as xs:string? := $zip-info/zip-geo:place_name[. ne '']
  let $state as xs:string? := $zip-info/zip-geo:admin_code1[. ne '']
  return
    if ($zip and $city and $state) then
      ($city, $state, $zip)
    else
      trns:get-random-city-state-zip()
};

declare function trns:get-random-state()
{
  "NY"
};

declare function trns:get-gender($gender-code as xs:string)
{
  if ($gender-code = "1") then
    "Male"
  else
    "Female"
};

declare function trns:get-race($race-code as xs:string)
{
  switch($race-code)
    case '1' return
      (2106-3, "White")
    case '2' return
      (2056-0, 'Black')
    case '5' return
      ('2135-2', 'Hispanic or Latino')
    default return
      ('2131-1', 'Other Race')
};

declare function trns:format-time($time as xs:dateTime)
{
  fn:substring(fn:replace(fn:string($time), "[-:T]", ""), 1, 14)
};

declare function trns:get-state-from-code($code as xs:string)
{
  let $lookup := xdmp:from-json-string('{"01": "AL","02": "AK","03": "AZ","04": "AR","05": "CA","06": "CO","07": "CT","08": "DE","09": "DC","10": "FL","11": "GA","12": "HI","13": "ID","14": "IL","15": "IN","16": "IA","17": "KS","18": "KY","19": "LA","20": "ME","21": "MD","22": "MA","23": "MI","24": "MN","25": "MS","26": "MO","27": "MT","28": "NE","29": "NV","30": "NH","31": "NJ","32": "NM","33": "NY","34": "NC","35": "ND","36": "OH","37": "OK","38": "OR","39": "PA","41": "RI","42": "SC","43": "SD","44": "TN","45": "TX","46": "UT","47": "VT","49": "VA","50": "WA","51": "WV","52": "WI","53": "WY","54": "O"}')
  return
    map:get($lookup, $code)
};

declare function trns:random-id()
{
  fn:upper-case(sem:uuid-string())
};

declare function trns:icd9-to-snomed($icd9 as xs:string?) as xs:string?
{
  if ($icd9) then
    let $icd9 := fn:replace($icd9, "\.", "")
    return
      /icd9-to-snomed[ICD_CODE = $icd9]/SNOMED_CID
  else ()
};


declare function trns:generate-doctor($npi as xs:string)
{
  let $provider := cts:search(/cms:provider, cts:element-range-query(xs:QName("cms:npi"), "=", $npi, "collation=http://marklogic.com/collation/codepoint"), "unfiltered")
  let $addr := $provider/cms:addresses/cms:address[@type="location address"]
  let $phone := (fn:replace($addr/cms:phone, "(\d\d\d)(\d\d\d)(\d\d\d\d)", "tel:+1-$1-$2-$3")[. ne ''], trns:get-random-phone())[1]
  return
    <assignedEntity xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <id extension="{$npi}" root="2.16.840.1.113883.4.6"/>
      <addr use="WP">
        <streetAddressLine>{$addr/cms:addr-line1/fn:string()}</streetAddressLine>
        <city>{$addr/cms:city/fn:string()}</city>
        <state>{$addr/cms:state/fn:string()}</state>
        <postalCode>{$addr/cms:zip5/fn:string()}</postalCode>
      </addr>
      <telecom use="WP" value="{$phone}"/>
      <assignedPerson>
        <realmCode code="US"/>
        <name>
          <given>{$provider/cms:first-name/fn:string()}</given>
          <family>{$provider/cms:last-name/fn:string()}</family>
          <suffix>{$provider/cms:name-suffix/fn:string()}</suffix>
        </name>
      </assignedPerson>
      <representedOrganization>
        <id root="2.16.840.1.113883.4.450"/>
        <name>ExactData County Medical Center</name>
        <telecom nullFlavor="UNK" use="WP"/>
        <addr nullFlavor="UNK" use="WP"/>
      </representedOrganization>
    </assignedEntity>
};

declare function trns:generate-problems-from-summary($doc, $time, $zip)
{
  let $low-time := "fix me"
  let $problems := (
    if ($doc/*:SP_ALZHDMTA = "1") then
      <problem>
        <name>Alzheimer''s disease</name>
        <snomed>26929004</snomed>
        <icd9>331.0</icd9>
      </problem>
    else (),

    if ($doc/*:SP_CHF = "1") then
      <problem>
        <name>Heart Failure</name>
        <snomed>42343007</snomed>
        <icd9>428.0</icd9>
      </problem>
    else (),

    if ($doc/*:SP_CHRNKIDN = "1") then
      <problem>
        <name>Kidney Disease</name>
        <snomed>236425005</snomed>
        <icd9>585.9</icd9>
      </problem>
    else (),

    if ($doc/*:SP_CNCR = "1") then
      let $cancer-icd9 := trns:random-name((1400 to 1729), 330)
      let $normalized-code := fn:replace(fn:string($cancer-icd9), "(\d\d\d)(\d)", "$1.$2")
      let $snomed := trns:icd9-to-snomed($normalized-code)
      let $name := map:get($codes:ICD9-DIAGNOSIS-CODES, fn:string($cancer-icd9))
      return
        <problem>
          <name>{$name}</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$normalized-code}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_COPD = "1") then
      let $icd9 := "490"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Chronic Obstructive Pulmonary Disease</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_DEPRESSN = "1") then
      let $icd9 := "311"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Depressive Disorder</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_DIABETES = "1") then
      let $icd9 := "250.00"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Diabetes mellitus</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_ISCHMCHT = "1") then
      let $icd9 := "410.00"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Ischemic Heart Disease</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_OSTEOPRS = "1") then
      let $icd9 := "733.00"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Osteoporosis</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_RA_OA = "1") then
      let $icd9 := "714.0"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Rheumatoid Arthritis</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else (),

    if ($doc/*:SP_STRKETIA = "1") then
      let $icd9 := "434.91"
      let $snomed := trns:icd9-to-snomed($icd9)
      return
        <problem>
          <name>Stroke</name>
          <snomed>{$snomed}</snomed>
          <icd9>{$icd9}</icd9>
        </problem>
    else ()
  )
  where $problems
  return
    <component xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <!--Problems Section-->
      <section>
        <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.3.88.11.83.103"/>
        <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.3.6"/>
        <templateId assigningAuthorityName="HL7 CCD" root="2.16.840.1.113883.10.20.1.11"/>
        <!--Problem section template-->
        <code code="11450-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Problems"/>
        <title>Problems</title>
        <text>
          <table border="1" width="100%">
            <thead>
              <tr>
                <th>Problem</th>
                <th>Status</th>
                <th>Onset Date</th>
                <th>Resolution Date</th>
              </tr>
            </thead>
            <tbody>
            {
              for $problem at $i in $problems
              return
                <tr>
                  <td ID="problem-{$i}">{$problem/*:name/fn:string()}</td>
                  <td ID="problem-status-{$i}">Active</td>
                  <td>6/11/2004</td>
                  <td>Ongoing</td>
                </tr>
            }
            </tbody>
          </table>
        </text>
        {
          for $problem at $i in $problems
          let $problem-id := trns:random-id()
          return
            <entry typeCode="DRIV">
              <act classCode="ACT" moodCode="EVN">
                <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.27"/>
                <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.7"/>
                <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.5.2"/>
                <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.5.1"/>
                <!--Problem act template-->
                <id root="{$problem-id}"/>
                <code nullFlavor="NA"/>
                <statusCode code="active"/>
                <effectiveTime>
                  <low value="{$low-time}"/>
                </effectiveTime>
                <performer typeCode="PRF">
                  <time>
                    <low value="{$time}"/>
                    <high value="{$time}"/>
                  </time>
                  {trns:generate-doctor(trns:random-name(trns:get-npis-from-zip($zip)))}
                </performer>
                <entryRelationship inversionInd="false" typeCode="SUBJ">
                  <observation classCode="OBS" moodCode="EVN">
                    <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.28"/>
                    <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.5"/>
                    <!--Problem observation template-->
                    <id root="{$problem-id}"/>
                    <code code="64572001" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Disease"/>
                    <text>
                      <reference value="#problem-{$i}"/>
                    </text>
                    <statusCode code="completed"/>
                    <effectiveTime>
                      <low value="{$time}"/>
                    </effectiveTime>
                    <value code="{$problem/*:snomed/fn:string()}" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="{$problem/*:name/fn:string()}" xsi:type="CD">
                      <translation code="{$problem/*:icd9/fn:string()}" codeSystem="2.16.840.1.113883.6.103" codeSystemName="ICD9" displayName="{$problem/*:name/fn:string()}"/>
                    </value>
                    <entryRelationship inversionInd="false" typeCode="REFR">
                      <observation classCode="OBS" moodCode="EVN">
                        <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.50"/>
                        <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.57"/>
                        <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.1.1"/>
                        <code code="33999-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Status"/>
                        <text>
                          <reference value="#problem-status-{$i}"/>
                        </text>
                        <statusCode code="completed"/>
                        <value code="55561003" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Active" xsi:type="CE"/>
                      </observation>
                    </entryRelationship>
                  </observation>
                </entryRelationship>
              </act>
            </entry>
        }
      </section>
    </component>
};

declare function trns:generate-problems($rows, $entries)
{
  <component xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <!--Problems Section-->
    <section>
      <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.3.88.11.83.103"/>
      <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.3.6"/>
      <templateId assigningAuthorityName="HL7 CCD" root="2.16.840.1.113883.10.20.1.11"/>
      <!--Problem section template-->
      <code code="11450-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Problems"/>
      <title>Problems</title>
      <text>
        <table border="1" width="100%">
          <thead>
            <tr>
              <th>Problem</th>
              <th>Status</th>
              <th>Onset Date</th>
              <th>Resolution Date</th>
            </tr>
          </thead>
          <tbody>
            {$rows}
          </tbody>
        </table>
      </text>
      {$entries}
    </section>
  </component>
};

declare function trns:generate-vitals($rows, $entries)
{
  <component xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <!--Problems Section-->
    <section>
      <templateId assigningAuthorityName="HL7 CCD" root="2.16.840.1.113883.10.20.1.16"/>
      <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.3.88.11.83.119"/>
      <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.1.5.3.2"/>
      <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.3.25"/>
      <!--Vital Signs section template-->
      <code code="8716-3" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Vital signs"/>
      <title>Vital Signs</title>
      <text>
        <table border="1" width="100%">
          <thead>
            <tr>
              <th>Date</th>
              <th>Body height</th>
              <th>Body weight</th>
              <th>Respiration Rate</th>
              <th>Pulse</th>
              <th>Systolic BP</th>
              <th>Diastolic BP</th>
              <th>Temperature</th>
            </tr>
          </thead>
          <tbody>
            {$rows}
          </tbody>
        </table>
      </text>
      {$entries}
    </section>
  </component>
};

declare function trns:get-procedures-section($patient as element(hl7:ClinicalDocument))
{
  $patient//hl7:section[hl7:templateId/@root="2.16.840.1.113883.10.20.1.12"]
};

declare function trns:generate-procedures($rows, $entries)
{
  <component xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <!--Procedure Section-->
    <section>
      <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.12"/>
      <code code="47519-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="History of procedures"/>
      <title>Procedures</title>
      <text>
        <table border="1" width="100%">
          <thead>
            <tr>
              <th>Procedure</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            {$rows}
          </tbody>
        </table>
      </text>
      {$entries}
    </section>
  </component>
};


declare function trns:add-problem($patient as element(hl7:ClinicalDocument), $claim as element())
{
  let $problems-section := $patient//hl7:section[hl7:templateId/@root="2.16.840.1.113883.3.88.11.83.103"]
  let $tbody := $problems-section/hl7:text/hl7:table/hl7:tbody
  let $existing := fn:count($tbody/hl7:tr)
  let $map := map:map()
  let $_ :=
    for $diagnosis at $icd-num in $claim/*:diagnoses/*:diagnosis[@type="icd9"]
    let $icd9 as xs:string := $diagnosis/*:code
    let $problem-index := $existing + $icd-num
    let $problem-name as xs:string? := $diagnosis/*:name
    let $snomed := trns:icd9-to-snomed($icd9)
    let $problem-id := trns:random-id()
    let $low-time := trns:parse-date($claim/*:from)
    let $high-time := trns:parse-date($claim/*:to)
    let $tr :=
      <tr xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <td ID="problem-{$problem-index}">{$problem-name}</td>
        <td ID="problem-status-{$problem-index}">Active</td>
        <td>{$low-time}</td>
        <td>Ongoing</td>
      </tr>
    let $entry :=
      <entry typeCode="DRIV" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <act classCode="ACT" moodCode="EVN">
          <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.27"/>
          <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.7"/>
          <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.5.2"/>
          <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.5.1"/>
          <!--Problem act template-->
          <id root="{$problem-id}"/>
          <code nullFlavor="NA"/>
          <statusCode code="active"/>
          <effectiveTime>
            <low value="{$low-time}"/>
          </effectiveTime>
          <performer typeCode="PRF">
            <time>
              <low value="{$low-time}"/>
              <high value="{$high-time}"/>
            </time>
            {
              trns:generate-doctor(
                trns:random-name(
                  trns:get-npis-from-cpt(
                    $claim/*:procedures/*:procedure[@type="cpt"]/*:code,
                    $patient/hl7:recordTarget/hl7:patientRole/hl7:addr/cts:point(@lat, @lng))
                )
              )
            }
          </performer>
          <entryRelationship inversionInd="false" typeCode="SUBJ">
            <observation classCode="OBS" moodCode="EVN">
              <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.28"/>
              <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.5"/>
              <!--Problem observation template-->
              <id root="{$problem-id}"/>
              <code code="64572001" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Disease"/>
              <text>
                <reference value="#problem-{$problem-index}"/>
              </text>
              <statusCode code="completed"/>
              <effectiveTime>
                <low value="{$low-time}"/>
              </effectiveTime>
              <value code="{$snomed}" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="{$problem-name}" xsi:type="CD">
                <translation code="{$icd9}" codeSystem="2.16.840.1.113883.6.103" codeSystemName="ICD9" displayName="{$problem-name}"/>
              </value>
              <entryRelationship inversionInd="false" typeCode="REFR">
                <observation classCode="OBS" moodCode="EVN">
                  <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.50"/>
                  <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.57"/>
                  <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.1.1"/>
                  <code code="33999-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Status"/>
                  <text>
                    <reference value="#problem-status-{$problem-index}"/>
                  </text>
                  <statusCode code="completed"/>
                  <value code="55561003" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Active" xsi:type="CE"/>
                </observation>
              </entryRelationship>
            </observation>
          </entryRelationship>
        </act>
      </entry>
    return
    (
      map:put($map, "rows", (map:get($map, "rows"), $tr)),
      map:put($map, "entries", (map:get($map, "entries"), $entry))
    )
  let $rows := map:get($map, "rows")
  let $entries := map:get($map, "entries")
  return
    if (fn:exists($rows) and fn:exists($entries)) then
      if ($problems-section) then
        trns:add-rows-and-sections-walk(
          $patient,
          "2.16.840.1.113883.10.20.1.11",
          $rows,
          $entries)
      else
        trns:add-component-walk(
          $patient,
          trns:generate-problems($rows, $entries))
    else
      $patient
};

declare function trns:add-vitals($patient as element(hl7:ClinicalDocument), $vitals as element(vital)*)
{
  let $problems-section := $patient//hl7:section[hl7:templateId/@root="2.16.840.1.113883.3.88.11.83.103"]
  let $tbody := $problems-section/hl7:text/hl7:table/hl7:tbody
  let $existing := fn:count($tbody/hl7:tr)
  let $low-time := fn:current-dateTime()
  let $map := map:map()
  let $_ :=
    for $vital in $vitals
    let $_ := xdmp:log(("vital:", $vital))
    let $type as xs:string := $vital/*:type
    let $value as xs:string := $vital/*:value
    let $vital-index :=
      switch ($type)
        case "height" return 1
        case "weight" return 2
        case "respiration" return 3
        case "pulse" return 4
        case "systolic" return 5
        case "diastolic" return 6
        case "temp" return 7
        default return ()
    let $code :=
      switch ($type)
        case "height" return
          <code xmlns="urn:hl7-org:v3" code="8302-2" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Body height"/>
        case "weight" return
          <code xmlns="urn:hl7-org:v3" code="3141-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Body weight"/>
        case "respiration" return
          <code xmlns="urn:hl7-org:v3" code="9279-1" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="RESPIRATION RATE"/>
        case "pulse" return
          <code xmlns="urn:hl7-org:v3" code="8867-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="HEART BEAT"/>
        case "systolic" return
          <code xmlns="urn:hl7-org:v3" code="8480-6" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Systolic BP"/>
        case "diastolic" return
          <code xmlns="urn:hl7-org:v3" code="8462-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Diastolic BP"/>
        case "temp" return
          <code xmlns="urn:hl7-org:v3" code="8310-5" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="BODY TEMPERATURE"/>
        default return ()
    let $units as xs:string := $vital/*:units
      (:switch($type)
        case "height" return "cm"
        case "weight" return "kg"
        case "respiration" return "/min"
        case "heart-rate" return "/min"
        case "systolic" return "mm[Hg]"
        case "diastolic" return "mm[Hg]"
        case "temp" return "Cel"
        default return ():)
    return
      map:put($map, fn:string($vital-index), <vital type="{$type}" units="{$units}" value="{$value}">{$code}</vital>)

  let $rows :=
    <tr xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <td>{$low-time}</td>
      {
        for $i in (1 to 7)
        let $vital := map:get($map, fn:string($i))
        return
          <td ID="vital_{$i}">
          {
            if ($vital) then
              $vital/@value || " " || $vital/@units
            else ()
          }
          </td>
      }
    </tr>
  let $entries :=
    <entry typeCode="DRIV" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <organizer classCode="CLUSTER" moodCode="EVN">
        <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.32"/>
        <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.35"/>
        <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.13.1"/>
        <!--Vital signs organizer template-->
        <id root="{trns:random-id()}"/>
        <code code="46680005" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Vital signs"/>
        <statusCode code="completed"/>
        <effectiveTime value="{fn:format-dateTime($low-time, "[Y0001][M01][D01][H01][m01][s01]")}"/>
        {
          for $key in map:keys($map)
          let $vital := map:get($map, $key)
          let $units as xs:string := $vital/@units
          let $value as xs:string := $vital/@value
          let $code := $vital/*
          return
            <component>
              <observation classCode="OBS" moodCode="EVN">
                <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.13.2"/>
                <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.13"/>
                <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.31"/>
                <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.3.88.11.83.14"/>
                <!--Result observation template-->
                <id root="{trns:random-id()}"/>
                {$code}
                <text>
                  <reference value="#vital-{$key}"/>
                </text>
                <statusCode code="completed"/>
                <effectiveTime value="{$low-time}"/>
                <value unit="{$units}" value="{$value}" xsi:type="PQ"/>
              </observation>
            </component>
        }
      </organizer>
    </entry>
  return
    if (fn:exists($rows) and fn:exists($entries)) then
      if ($problems-section) then
        trns:add-rows-and-sections-walk(
          $patient,
          "2.16.840.1.113883.10.20.1.16",
          $rows,
          $entries)
      else
        trns:add-component-walk(
          $patient,
          trns:generate-vitals($rows, $entries))
    else
      $patient
};

declare function trns:generate-medications($rows, $entries)
{
  <component xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <!--Medications Section-->
    <section>
      <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.3.88.11.83.112"/>
      <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.3.19"/>
      <templateId assigningAuthorityName="HL7 CCD" root="2.16.840.1.113883.10.20.1.8"/>
      <code code="10160-0" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="History of medication use"/>
      <title>Medications</title>
      <text>
        <table border="1" width="100%">
          <thead>
            <tr>
              <th>Medication</th>
              <th>Dosage</th>
              <th>Days Supplied</th>
              <th>Last Filled Date</th>
              <th>Refills Remaining</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {$rows}
          </tbody>
        </table>
      </text>
      {$entries}
    </section>
  </component>
};
declare function trns:add-rx($patient as element(hl7:ClinicalDocument), $claim as element())
{
  let $medications-section := $patient//hl7:section[hl7:templateId/@root="2.16.840.1.113883.10.20.1.8"]
  let $tbody := $medications-section/hl7:text/hl7:table/hl7:tbody
  let $existing := fn:count($tbody/hl7:tr)
  let $map := map:map()
  let $_ :=
    let $medication-id:= trns:random-id()
    let $low-time as xs:date? := $claim/*:rx-service-date
    let $ndc as xs:string := $claim/*:ndc
    let $medication-index := $existing + 1
    let $quantity as xs:string := $claim/*:quantity
    let $drug-name as xs:string? := $claim/*:drug-name
    let $refills-remaining := ($claim/*:days-supply/xs:int(.), 0)[1] div 30
    let $dosage := trns:random-name(
      for $i in (1 to 40, 40)
      return
        ($i * 5) || ' mg')
    let $tr :=
      <tr xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <td>
          <content ID="med-{$medication-index}">{$drug-name}</content>
        </td>
        <td>{$dosage}</td>
        <td>{$quantity}</td>
        <td>{$low-time}</td>
        <td>{$refills-remaining}</td>
        <td>Completed</td>
      </tr>
    let $entry :=
      <entry typeCode="DRIV" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <substanceAdministration classCode="SBADM" moodCode="EVN">
          <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.8"/>
          <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.24"/>
          <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.7"/>
          <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.7.1"/>
          <id root="{$medication-id}"/>
          <statusCode code="completed"/>
          <effectiveTime xsi:type="IVL_TS">
            <low value="{$low-time}"/>
            <high nullFlavor="UNK"/>
          </effectiveTime>
          {
            let $splits := fn:tokenize($dosage, ' ')
            return
              <doseQuantity unit="{$splits[2]}" value="{$splits[1]}"/>
          }
          <consumable>
            <manufacturedProduct>
              <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.8.2"/>
              <templateId root="2.16.840.1.113883.10.20.1.53"/>
              <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.7.2"/>
              <manufacturedMaterial>
                <code code="{$ndc}" codeSystem="2.16.840.1.113883.6.69" codeSystemName="NDC" displayName="{$drug-name}">
                  <originalText>
                    <reference value="#med-{$medication-index}"/>
                  </originalText>
                </code>
                <name>{$drug-name}</name>
              </manufacturedMaterial>
            </manufacturedProduct>
          </consumable>
          <entryRelationship typeCode="SUBJ">
            <observation classCode="OBS" moodCode="EVN">
              <templateId root="2.16.840.1.113883.3.88.11.83.8.1"/>
              <code code="73639000" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Prescription Drug"/>
              <statusCode code="completed"/>
            </observation>
          </entryRelationship>
          <entryRelationship typeCode="REFR">
            <supply classCode="SPLY" moodCode="INT">
              <templateId root="2.16.840.1.113883.3.88.11.83.8.3"/>
              <templateId root="1.3.6.1.4.1.19376.1.5.3.1.4.7.3"/>
              <templateId root="2.16.840.1.113883.10.20.1.34"/>
              <id extension="130425-94706" root="2.16.840.1.113883.4.450"/>
              <repeatNumber value="1"/>
              <quantity unit="{{UNASSIGNED}}" value="{$quantity}"/>
              <author>
                <time value="{$low-time}"/>
                <assignedAuthor>
                {
                  let $zip as xs:string := $patient/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:postalCode
                  return
                    trns:generate-doctor(trns:random-name(trns:get-npis-from-zip($zip)))/*
                }
                </assignedAuthor>
              </author>
            </supply>
          </entryRelationship>
        </substanceAdministration>
      </entry>
    where fn:exists($drug-name[. ne ''])
    return
    (
      map:put($map, "rows", (map:get($map, "rows"), $tr)),
      map:put($map, "entries", (map:get($map, "entries"), $entry))
    )
  let $rows := map:get($map, "rows")
  let $entries := map:get($map, "entries")
  return
    if (fn:exists($rows) and fn:exists($entries)) then
      if ($medications-section) then
        trns:add-rows-and-sections-walk(
          $patient,
          "2.16.840.1.113883.10.20.1.8",
          $rows,
          $entries)
      else
        trns:add-component-walk(
          $patient,
          trns:generate-medications($rows, $entries))
    else
      $patient
};

declare function trns:add-component-walk(
  $nodes as node()*,
  $component as element(hl7:component))
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(hl7:structuredBody) return
        element { fn:node-name($n) }
        {
          $n/namespace::*,
          $n/@*,
          $n/node(),
          $component
        }
      case element() return
        element { fn:node-name($n) }
        {
          $n/namespace::*,
          $n/@*,
          trns:add-component-walk($n/node(), $component)
        }
      default return
        $n
};

declare function trns:add-rows-and-sections-walk(
  $nodes as node()*,
  $section-code as xs:string,
  $rows as element(hl7:tr)*,
  $entries as element(hl7:entry)*)
{
  for $n in $nodes
  return
    typeswitch($n)
      case element(hl7:tbody) return
        element { fn:node-name($n) }
        {
          $n/namespace::*,
          $n/@*,
          trns:add-rows-and-sections-walk($n/node(), $section-code, $rows, $entries),
          if ($n/ancestor::hl7:section/hl7:templateId/@root = $section-code) then
            $rows
          else ()
        }
      case element(hl7:section) return
        element { fn:node-name($n) }
        {
          $n/namespace::*,
          $n/@*,
          trns:add-rows-and-sections-walk($n/node(), $section-code, $rows, $entries),
          if ($n/hl7:templateId/@root = $section-code) then
           $entries
          else ()
        }
      case element() return
        element { fn:node-name($n) }
        {
          $n/@*,
          trns:add-rows-and-sections-walk($n/node(), $section-code, $rows, $entries)
        }
      default return
        $n
};

declare function trns:get-hcpcs-name($cpt-code) as xs:string?
{
  map:get($codes:CPT-CODES, $cpt-code)
};

declare function trns:add-procedure($patient as element(hl7:ClinicalDocument), $claim as element())
{
  let $procedures-section := trns:get-procedures-section($patient)
  let $tbody := $procedures-section/hl7:text/hl7:table/hl7:tbody
  let $existing := fn:count($tbody/hl7:tr)
  let $map := map:map()
  let $_ :=
    for $procedure at $icd-num in $claim/*:procedures/*:procedure[@type="icd9"]
    let $icd9 as xs:string := $procedure/*:code
    let $procedure-index := $existing + $icd-num
    let $procedure-name as xs:string? := $procedure/*:name
    let $snomed := trns:icd9-to-snomed($icd9)
    let $procedure-id := trns:random-id()
    let $low-time := trns:parse-date($claim/*:from)
    let $high-time := trns:parse-date($claim/*:to)
    let $tr :=
      <tr xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <td>
          <content ID="procedure-{$procedure-index}">{$procedure-name}</content>
        </td>
        <td>{$low-time}</td>
      </tr>
    let $entry :=
      <entry xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <procedure classCode="PROC" moodCode="EVN">
          <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.17"/>
          <templateId assigningAuthorityName="CCD" root="2.16.840.1.113883.10.20.1.29"/>
          <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.19"/>
          <id root="{$procedure-id}"/>
          <code code="{$icd9}" codeSystem="2.16.840.1.113883.6.104" codeSystemName="ICD9" displayName="{$procedure-name}">
            <originalText>
              <reference value="#procedure-{$procedure-index}"/>
            </originalText>
            <qualifier/>
          </code>
          <text>
            <reference value="#procedure-{$procedure-index}"/>
          </text>
          <statusCode code="completed"/>
          <effectiveTime>
            <low value="{$low-time}"/>
            <high value="{$high-time}"/>
          </effectiveTime>
          <performer>
            {
              trns:generate-doctor(
                trns:random-name(
                  trns:get-npis-from-cpt(
                    $claim/*:procedures/*:procedure[@type="cpt"]/*:code,
                    $patient/hl7:recordTarget/hl7:patientRole/hl7:addr/cts:point(@lat, @lng))
                )
              )
          }
          </performer>
        </procedure>
      </entry>
    where $icd9 and $procedure-name and $snomed
    return
    (
      map:put($map, "rows", (map:get($map, "rows"), $tr)),
      map:put($map, "entries", (map:get($map, "entries"), $entry))
    )
  let $rows := map:get($map, "rows")
  let $entries := map:get($map, "entries")
  return
    if (fn:exists($rows) and fn:exists($entries)) then
      if ($procedures-section) then
        trns:add-rows-and-sections-walk(
          $patient,
          "2.16.840.1.113883.10.20.1.12",
          $rows,
          $entries)
      else
        trns:add-component-walk(
          $patient,
          trns:generate-procedures($rows, $entries))
    else
      $patient
};

(:declare function trns:add-encounters($doc)
{
  let $encounters := ()
  return
    <component xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <!--Encounters Section-->
      <section>
        <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.127"/>
        <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3"/>
        <templateId assigningAuthorityName="HL7 CCD" root="2.16.840.1.113883.10.20.1.3"/>
        <!--Encounters section template-->
        <code code="46240-8" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="History of encounters"/>
        <title>Encounters</title>
        <text>
          <table border="1" width="100%">
            <thead>
              <tr>
                <th>Date</th>
                <th>Encounter</th>
                <th>Performer</th>
                <th>Location</th>
                <th>Notes</th>
              </tr>
            </thead>
            <tbody>
              {
                for $encounter at $i in $encounters
                return
                  <tr>
                    <td>2013-04-25T14:30:00Z</td>
                    <td>
                      <content ID="encounter-{$i}">Walk-In</content>
                    </td>
                    <td>Thérèse Castro PA-C</td>
                    <td>Partners in Primary Care</td>
                    <td>
                      <content ID="encounter-note-{$i}">s:31 yo male urologist presents with mild epigastric pain for 4 days. patient also reports Stomach. he has a history of smoking he is a heavy drinker o:Height 74 in, Weight 189 lbs, Temperature 99.1 F, Pulse 85, SystolicBP 113, DiastolicBP 76, Respiration 17, Heart = RRR, Normal S1/S2, no murmurs, Abdomen = mild tenderness to deep palpitation a:Ulcers p:performed E/M Level 3 (new patient) - Completed, and prescribed famotidine - 40 mg daily, and ordered serum helicobacter pylori assay.</content>
                    </td>
                  </tr>
              }
            </tbody>
          </table>
        </text>
        {
          for $encounter at $i in $encounters
          let $act-code := "AMB" (: or IMP for inpatient :)
          let $act-name := "Ambulatory" (: or Inpatient Encounter :)
          let $cpt-code as xs:string? := $doc/*:HCPCS_CD_1
          let $cpt-name as xs:string? := /codes[@state="any" and field="cpt-hcpcs"]/code[@key=$cpt-code]
          return
            <entry typeCode="DRIV">
              <encounter classCode="ENC" moodCode="EVN">
                <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.3.88.11.83.16"/>
                <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.4.14"/>
                <templateId assigningAuthorityName="HITSP/C83" root="2.16.840.1.113883.10.20.1.21"/>
                <!--Encounter activity template-->
                <id extension="76485937638497963885" root="2.16.840.1.113883.4.450"/>
                <code code="{$cpt-code}" codeSystem="2.16.840.1.113883.6.12" codeSystemName="CPT" codeSystemVersion="4" displayName="{$cpt-name}">
                  <originalText>
                    <reference value="#encounter-{$i}"/>
                  </originalText>
                  <translation code="{$act-code}" codeSystem="2.16.840.1.113883.5.4" codeSystemName="ActEncounterCode" displayName="{$act-name}"/>
                </code>
                <text>
                  <reference value="#encounter-note-{$i}"/>
                </text>
                <effectiveTime>
                  <low value="20130425143000"/>
                  <high value="20130425143000"/>
                </effectiveTime>
                <performer typeCode="PRF">
                  <time>
                    <high value="20130425143000"/>
                  </time>
                  <assignedEntity>
                    <id extension="872813010" root="2.16.840.1.113883.4.450"/>
                    <addr use="WP">
                      <streetAddressLine>9400 Rand Drive</streetAddressLine>
                      <city>Colden</city>
                      <state>NY</state>
                      <postalCode>14033</postalCode>
                    </addr>
                    <telecom use="WP" value="tel:+1-740-469-0134"/>
                    <assignedPerson>
                      <realmCode code="US"/>
                      <name>
                        <given>Thérèse</given>
                        <family>Castro</family>
                        <suffix>PA-C</suffix>
                      </name>
                    </assignedPerson>
                    <representedOrganization>
                      <id nullFlavor="UNK"/>
                      <name>Partners in Primary Care</name>
                      <telecom use="WP" value="tel:+1-740-469-0134"/>
                      <addr use="WP">
                        <streetAddressLine>9400 Rand Drive</streetAddressLine>
                        <city>Colden</city>
                        <state>NY</state>
                        <postalCode>14033</postalCode>
                      </addr>
                    </representedOrganization>
                  </assignedEntity>
                </performer>
                <participant typeCode="LOC">
                  <participantRole classCode="SDLOC">
                    <addr use="WP">
                      <streetAddressLine>9400 Rand Drive</streetAddressLine>
                      <city>Colden</city>
                      <state>NY</state>
                      <postalCode>14033</postalCode>
                    </addr>
                    <telecom use="WP" value="tel:+1-740-469-0134"/>
                    <playingEntity>
                      <name>Partners in Primary Care</name>
                    </playingEntity>
                  </participantRole>
                </participant>
              </encounter>
            </entry>
        }
      </section>
    </component>
};:)


declare function trns:build-patient($doc as element())
{
  let $ssn := trns:get-ssn($doc/*:DESYNPUF_ID)
  let $time := trns:format-time(fn:current-dateTime())
  let $city-state-zip := trns:get-random-city-state-zip()
  return
    <ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <realmCode code="US"/>
      <typeId extension="POCD_HD000040" root="2.16.840.1.113883.1.3"/>
      <templateId root="2.16.840.1.113883.10.20.3"/>
      <templateId root="1.3.6.1.4.1.19376.1.5.3.1.1.1"/>
      <templateId assigningAuthorityName="HITSP/C32" root="2.16.840.1.113883.3.88.11.32.1"/>
      <id root="{trns:random-id()}"/>
      <code code="34133-9" codeSystem="2.16.840.1.113883.6.1" displayName="Summarization of episode note"/>
      <title>Continuity of Care Document</title>
      <effectiveTime value="{$time}"/>
      <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
      <languageCode code="en-US"/>
      <recordTarget>
        <patientRole>
          { comment { "Patient ID " || fn:replace($ssn, "-", "") } }
          <id extension="{$ssn}" root="2.16.840.1.113883.4.1"/>
          { (:let $state := trns:get-state-from-code($doc/*:SP_STATE_CODE):) }
          {
            let $zip := $city-state-zip[3]
            let $zip-info := /zip-geo:zip_geo[zip-geo:postal = $zip]
            return
              element addr {
                attribute use {"HP"},
                if ($zip-info) then
                (
                  attribute lat { $zip-info/zip-geo:latitude/fn:data(.) },
                  attribute lng { $zip-info/zip-geo:longitude/fn:data(.) }
                )
                else (),
                element streetAddressLine {trns:get-random-address() },
                element city { $city-state-zip[1] },
                element state { $city-state-zip[2] },
                element postalCode { $city-state-zip[3] }
              }
          }
          <telecom use="HP" value="{trns:get-random-phone()}"/>
          <patient>
          {
            let $gender := trns:get-gender($doc/*:BENE_SEX_IDENT_CD)
            let $code := fn:substring($gender, 1, 1)
            let $first-name :=
              if ($code eq "F") then
                trns:random-name($FEMALE-FIRST-NAMES, $FEMALE-FIRST-NAMES-COUNT)
              else
                trns:random-name($MALE-FIRST-NAMES, $MALE-FIRST-NAMES-COUNT)
            return
            (
              <name>
                <given>{$first-name}</given>
                <given>{trns:random-name($MIDDLE-NAMES, $MIDDLE-NAMES-COUNT)}</given>
                <family>{trns:random-name($LAST-NAMES, $LAST-NAMES-COUNT)}</family>
              </name>,
              <administrativeGenderCode code="{$code}" codeSystem="2.16.840.1.113883.5.1" codeSystemName="HL7 AdministrativeGenderCodes" displayName="{$gender}"/>,

              <birthTime value="{$doc/*:BENE_BIRTH_DT/fn:data(.)}"/>,

              let $status := trns:random-name($MARITAL-STATUSES, $MARITAL-STATUSES-COUNT)
              let $code := fn:substring($status, 1, 1)
              return
                <maritalStatusCode code="{$code}" codeSystem="2.16.840.1.113883.5.2" codeSystemName="MaritalStatusCode" displayName="{$status}"/>,

              let $race := trns:get-race($doc/*:BENE_RACE_CD)
              return
                <raceCode code="{$race[1]}" codeSystem="2.16.840.1.113883.6.238" codeSystemName="CDC Race and Ethnicity" displayName="{$race[2]}"/>
            )
          }
            <languageCommunication>
              <templateId assigningAuthorityName="IHE PCC" root="1.3.6.1.4.1.19376.1.5.3.1.2.1"/>
              <templateId assigningAuthorityName="HITSP C83" root="2.16.840.1.113883.3.88.11.83.2"/>
              <languageCode code="en-US"/>
              <preferenceInd value="true"/>
            </languageCommunication>
          </patient>
        </patientRole>
      </recordTarget>
      <author>
        <time value="{$time}"/>
        <assignedAuthor>
          {trns:generate-doctor(trns:random-name(trns:get-npis-from-zip($city-state-zip[3])))/*}
        </assignedAuthor>
      </author>
      <custodian>
        <assignedCustodian>
          <representedCustodianOrganization>
            <id root="2.16.840.1.113883.4.450"/>
            <name>ExactData County Medical Center</name>
            <telecom nullFlavor="UNK" use="WP"/>
            <addr nullFlavor="UNK" use="WP"/>
          </representedCustodianOrganization>
        </assignedCustodian>
      </custodian>
      <participant typeCode="IND">
        <templateId root="2.16.840.1.113883.3.88.11.83.3"/>
        <templateId root="1.3.6.1.4.1.19376.1.5.3.1.2.4"/>
        <time value="{$time}"/>
        <associatedEntity classCode="ECON">
          <code code="FRND" codeSystem="2.16.840.1.113883.5.111" codeSystemName="RoleCode" displayName="unrelated friend"/>
          <addr/>
          <telecom use="HP" value="{trns:get-random-phone()}"/>
          <associatedPerson>
            <name>
              <given>{trns:random-name($FIRST-NAMES, $FIRST-NAMES-COUNT)}</given>
              <family>{trns:random-name($LAST-NAMES, $LAST-NAMES-COUNT)}</family>
            </name>
          </associatedPerson>
        </associatedEntity>
      </participant>
      <documentationOf>
        <serviceEvent classCode="PCPR">
          <effectiveTime>
            <low value="{$time}"/>
            <high value="{$time}"/>
          </effectiveTime>
          <performer typeCode="PRF">
            <templateId root="2.16.840.1.113883.3.88.11.83.4"/>
            <templateId root="1.3.6.1.4.1.19376.1.5.3.1.2.3"/>
            <functionCode code="PP" codeSystem="2.16.840.1.113883.12.443" codeSystemName="Provider Role" displayName="Primary Care Provider">
              <originalText>Primary Care Provider</originalText>
            </functionCode>
            <time>
              <low value="20140804151500"/>
              <high value="20140804151500"/>
            </time>
            {trns:generate-doctor(trns:random-name(trns:get-npis-from-zip($city-state-zip[3])))}
          </performer>
          <performer typeCode="PRF">
            <templateId root="2.16.840.1.113883.3.88.11.83.4"/>
            <templateId root="1.3.6.1.4.1.19376.1.5.3.1.2.3"/>
            <functionCode code="PP" codeSystem="2.16.840.1.113883.12.443" codeSystemName="Provider Role" displayName="Primary Care Provider">
              <originalText>Primary Care Provider</originalText>
            </functionCode>
            <time>
              <low value="{$time}"/>
              <high value="{$time}"/>
            </time>
            {trns:generate-doctor(trns:random-name(trns:get-npis-from-zip($city-state-zip[3])))}
          </performer>
        </serviceEvent>
      </documentationOf>
      <component>
        <structuredBody>
          <component>
            <!--Purpose section-->
            <section>
              <templateId root="2.16.840.1.113883.10.20.1.13"/>
              <!--Purpose section template-->
              <code code="48764-5" codeSystem="2.16.840.1.113883.6.1" displayName="Purpose"/>
              <title>Summary of Purpose</title>
              <text>Transfer of care</text>
              <entry typeCode="DRIV">
                <act classCode="ACT" moodCode="EVN">
                  <templateId root="2.16.840.1.113883.10.20.1.30"/>
                  <!--Purpose activity template-->
                  <code code="23745001" codeSystem="2.16.840.1.113883.6.96" displayName="Documentation procedure"/>
                  <statusCode code="completed"/>
                  <entryRelationship typeCode="RSON">
                    <act classCode="ACT" moodCode="EVN">
                      <code code="308292007" codeSystem="2.16.840.1.113883.6.96" displayName="Transfer of care"/>
                      <statusCode code="completed"/>
                    </act>
                  </entryRelationship>
                </act>
              </entry>
            </section>
          </component>
          {
            trns:generate-problems-from-summary($doc, $time, $city-state-zip[3])
          }
        </structuredBody>
      </component>
    </ClinicalDocument>
};

declare function trns:build-claim($doc as element(), $type as xs:string)
{
  let $ndc as xs:string? := $doc/*:PROD_SRVC_ID
  let $drug-name :=
    if ($type = "rx") then
      trns:get-drug-name-from-ndc($ndc)
    else ()
  return
    if ($type ne "rx" or ($type eq "rx" and fn:exists($drug-name[. ne '']))) then
      element claim {
        element type { fn:upper-case(fn:substring($type, 1, 1)) || fn:substring($type, 2) },
        element patient-ssn { trns:get-ssn($doc/*:DESYNPUF_ID) },
        element id { (xdmp:hash64($doc/*:DESYNPUF_ID), xdmp:random())[1] },
        $doc/*:CLM_FROM_DT[. ne '']/element from { trns:parse-date(.) },
        $doc/*:CLM_THRU_DT[. ne '']/element to { trns:parse-date(.) },
        $doc/*:CLM_PMT_AMT[. ne '']/element payment-amount { fn:data(.) },
        $doc/*:NCH_PRMRY_PYR_CLM_PD_AMT[. ne '']/element primary-payer-paid-amount { fn:data(.) },
        $doc/*:AT_PHYSN_NPI[. ne '']/element attending-npi { fn:data(.) },
        $doc/*:OP_PHYSN_NPI[. ne '']/element operating-npi { fn:data(.) },
        if ($doc/*:OT_PHYSN_NPI[. ne ''] and $doc/*:OT_PHYSN_NPI ne $doc/*:AT_PHYSN_NPI) then
          element other-npi { $doc/*:OT_PHYSN_NPI/fn:data(.) }
        else (),
        $doc/*:CLM_ADMSN_DT[. ne '']/element admission-date { trns:parse-date(.) },
        $doc/*:CLM_PASS_THRU_PER_DIEM_AMT[. ne '']/element pass-through-per-diem { fn:data(.) },
        $doc/*:NCH_BENE_IP_DDCTBL_AMT[. ne '']/element inpatient-deductible { fn:data(.) },
        $doc/*:NCH_BENE_PTB_DDCTBL_AMT[. ne '']/element bene-part-b-deductible-amount { fn:data(.) },
        $doc/*:NCH_BENE_PTB_COINSRNC_AMT[. ne '']/element bene-part-b-coinsurance-amount { fn:data(.) },
        $doc/*:NCH_BENE_PTA_COINSRNC_LBLTY_AM[. ne '']/element coinsurance-liability-amount { fn:data(.) },
        $doc/*:NCH_BENE_BLOOD_DDCTBL_LBLTY_AM[. ne '']/element blood-deductible-liability-amount { fn:data(.) },
        $doc/*:CLM_UTLZTN_DAY_CNT[. ne '']/element utilization-day-count { fn:data(.) },
        $doc/*:NCH_BENE_DSCHRG_DT[. ne '']/element discharge-date { trns:parse-date(.) },

        let $diagnosis-codes as xs:string* := $doc/(*:ICD9_DGNS_CD_1, *:ICD9_DGNS_CD_2, *:ICD9_DGNS_CD_3, *:ICD9_DGNS_CD_4, *:ICD9_DGNS_CD_5, *:ICD9_DGNS_CD_6, *:ICD9_DGNS_CD_7, *:ICD9_DGNS_CD_8, *:ICD9_DGNS_CD_9, *:ICD9_DGNS_CD_10)[. ne '']
        where fn:exists($diagnosis-codes)
        return
          element diagnoses {
            for $code in $diagnosis-codes
            return
              element diagnosis {
                attribute type { "icd9" },
                element code { $code },
                map:get($codes:ICD9-DIAGNOSIS-CODES, $code) ! element name { . }
              }
          },


        let $icd9-proc-codes as xs:string* := $doc/(*:ICD9_PRCDR_CD_1, *:ICD9_PRCDR_CD_2, *:ICD9_PRCDR_CD_3, *:ICD9_PRCDR_CD_4, *:ICD9_PRCDR_CD_5, *:ICD9_PRCDR_CD_6)[. ne '']
        let $procedure-codes as xs:string* := $doc/(*:HCPCS_CD_1,*:HCPCS_CD_2,*:HCPCS_CD_3,*:HCPCS_CD_4,*:HCPCS_CD_5,*:HCPCS_CD_6,*:HCPCS_CD_7,*:HCPCS_CD_8,*:HCPCS_CD_9,*:HCPCS_CD_10,*:HCPCS_CD_11,*:HCPCS_CD_12,*:HCPCS_CD_13,*:HCPCS_CD_14,*:HCPCS_CD_15,*:HCPCS_CD_16,*:HCPCS_CD_17,*:HCPCS_CD_18,*:HCPCS_CD_19,*:HCPCS_CD_20,*:HCPCS_CD_21,*:HCPCS_CD_22,*:HCPCS_CD_23,*:HCPCS_CD_24,*:HCPCS_CD_25,*:HCPCS_CD_26,*:HCPCS_CD_27,*:HCPCS_CD_28,*:HCPCS_CD_29,*:HCPCS_CD_30,*:HCPCS_CD_31,*:HCPCS_CD_32,*:HCPCS_CD_33,*:HCPCS_CD_34,*:HCPCS_CD_35,*:HCPCS_CD_36,*:HCPCS_CD_37,*:HCPCS_CD_38,*:HCPCS_CD_39,*:HCPCS_CD_40,*:HCPCS_CD_41,*:HCPCS_CD_42,*:HCPCS_CD_43,*:HCPCS_CD_44,*:HCPCS_CD_45)[. ne '']
        where fn:exists($icd9-proc-codes or $procedure-codes)
        return
          element procedures {
            for $code in $procedure-codes
            return
              element procedure {
                attribute type { "cpt" },
                element code { $code },
                trns:get-hcpcs-name($code) ! element name { . }
              },

            for $code in $icd9-proc-codes
            return
              element procedure {
                attribute type { "icd9" },
                element code { $code },
                map:get($codes:ICD9-PROCEDURE-CODES, $code) ! element name { . }
              }
          },


        (: rx :)
        $doc/*:SRVC_DT[. ne '']/element rx-service-date { trns:parse-date(.) },
        $doc/*:PROD_SRVC_ID[. ne '']/element ndc { fn:data(.) },
        $doc/*:QTY_DSPNSD_NUM[. ne '']/element quantity { fn:data(.) },
        $doc/*:DAYS_SUPLY_NUM[. ne '']/element days-supply { fn:data(.) },
        $doc/*:PTNT_PAY_AMT[. ne '']/element patient-pay-amount { fn:data(.) },
        $doc/*:TOT_RX_CST_AMT[. ne '']/element gross-drug-cost { fn:data(.) },
        $drug-name[. ne ''] ! element drug-name { . }
      }
    else if ($type eq "rx") then
      xdmp:log("NO DRUG NAME FOUND FOR: " || $ndc)
    else ()
};

declare function trns:update-patient-recursive($patient, $claims)
{
  let $claim := $claims[1]
  let $remaining := fn:subsequence($claims, 2)
  return
    if ($claim) then
      trns:update-patient-recursive(
        if ($claim/*:type = ("Inpatient", "Outpatient")) then
          trns:add-procedure(trns:add-problem($patient, $claim), $claim)
        else
          trns:add-rx($patient, $claim),
        $remaining)
    else
      $patient
};

declare function trns:update-patient($patient as element(hl7:ClinicalDocument))
{
  let $ssn as xs:string := $patient/hl7:recordTarget/hl7:patientRole/hl7:id[@root="2.16.840.1.113883.4.1"]/@extension
  let $claims := /claim[patient-ssn = $ssn]
  let $new-patient :=
    trns:update-patient-recursive($patient, $claims)
  return
    $new-patient
    (:xdmp:node-replace($patient, $new-patient):)
};

declare function trns:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
  let $doc := map:get($content, 'value')
  let $doc :=
    typeswitch($doc)
      case document-node() return
        $doc/*
      default return
        $doc
  let $output :=
    typeswitch($doc)
      case element(patient-summary) return
        trns:update-patient(trns:build-patient($doc))
      case element(outpatient-claim) return
        trns:build-claim($doc, "outpatient")
      case element(inpatient-claim) return
        trns:build-claim($doc, "inpatient")
      case element(rx-claim) return
        let $claim := trns:build-claim($doc, "rx")
        let $_ := map:put($content, "uri", "/claims/rx/" || $claim/id/fn:data() || ".xml")
        return
          $claim
      default return ()
  let $_ := map:put($content, 'value', document { $output })
  where $output
  return
    $content
};
