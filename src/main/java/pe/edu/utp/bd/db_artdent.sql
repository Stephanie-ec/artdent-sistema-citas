CREATE DATABASE  IF NOT EXISTS `db_artdent` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `db_artdent`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: db_artdent
-- ------------------------------------------------------
-- Server version	8.0.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cita`
--

DROP TABLE IF EXISTS `cita`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cita` (
  `idCita` int NOT NULL AUTO_INCREMENT,
  `DiaReserva` date NOT NULL,
  `HoraReserva` time NOT NULL,
  `Servicio_idServicio` int NOT NULL,
  `Paciente_idPaciente` int NOT NULL,
  `Estado_idEstado` int NOT NULL,
  `Odontologo_idUsuario` int NOT NULL,
  PRIMARY KEY (`idCita`),
  KEY `fk_Cita_Servicio1_idx` (`Servicio_idServicio`),
  KEY `fk_Cita_Paciente1_idx` (`Paciente_idPaciente`),
  KEY `fk_Cita_Estado1_idx` (`Estado_idEstado`),
  KEY `fk_Odontologo_cita` (`Odontologo_idUsuario`),
  CONSTRAINT `fk_Cita_Estado1` FOREIGN KEY (`Estado_idEstado`) REFERENCES `estado` (`idEstado`),
  CONSTRAINT `fk_Cita_Paciente1` FOREIGN KEY (`Paciente_idPaciente`) REFERENCES `paciente` (`idPaciente`),
  CONSTRAINT `fk_Cita_Servicio1` FOREIGN KEY (`Servicio_idServicio`) REFERENCES `servicio` (`idServicio`),
  CONSTRAINT `fk_Odontologo_cita` FOREIGN KEY (`Odontologo_idUsuario`) REFERENCES `usuario` (`idUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cita`
--

LOCK TABLES `cita` WRITE;
/*!40000 ALTER TABLE `cita` DISABLE KEYS */;
INSERT INTO `cita` VALUES (2,'2024-12-03','12:00:00',1,5,3,4),(3,'2024-12-10','14:30:00',1,6,1,4),(11,'2024-12-10','13:15:00',1,2,1,4);
/*!40000 ALTER TABLE `cita` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado`
--

DROP TABLE IF EXISTS `estado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado` (
  `idEstado` int NOT NULL AUTO_INCREMENT,
  `TipoEstado` varchar(50) NOT NULL,
  PRIMARY KEY (`idEstado`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado`
--

LOCK TABLES `estado` WRITE;
/*!40000 ALTER TABLE `estado` DISABLE KEYS */;
INSERT INTO `estado` VALUES (1,'En espera'),(2,'Completado'),(3,'Confirmado'),(4,'Reprogramado'),(5,'Cancelado');
/*!40000 ALTER TABLE `estado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `horario`
--

DROP TABLE IF EXISTS `horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `horario` (
  `idHorario` int NOT NULL AUTO_INCREMENT,
  `HoraInicio` time NOT NULL,
  `HoraFinal` time NOT NULL,
  `DiaSemana` varchar(15) NOT NULL,
  PRIMARY KEY (`idHorario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `horario`
--

LOCK TABLES `horario` WRITE;
/*!40000 ALTER TABLE `horario` DISABLE KEYS */;
INSERT INTO `horario` VALUES (1,'08:00:00','18:30:00','Lunes'),(2,'08:00:00','18:30:00','Martes'),(3,'08:00:00','18:30:00','Miércoles'),(4,'08:00:00','18:30:00','Jueves'),(5,'08:00:00','18:30:00','Viernes');
/*!40000 ALTER TABLE `horario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paciente`
--

DROP TABLE IF EXISTS `paciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paciente` (
  `idPaciente` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `Apellido` varchar(50) NOT NULL,
  `DNI` varchar(8) NOT NULL,
  `Telefono` varchar(9) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  PRIMARY KEY (`idPaciente`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paciente`
--

LOCK TABLES `paciente` WRITE;
/*!40000 ALTER TABLE `paciente` DISABLE KEYS */;
INSERT INTO `paciente` VALUES (1,'Carlos Gilberto','Pérez Gomez','48915516','987655321','carlos.perez@gmail.com'),(2,'Roy Makaay','Meza Taipe','74922216','951063543','U22205982@utp.edu.pe'),(3,'Andrea','Gallo','71851528','982244226','andreagallo21052005@gmail.com'),(4,'Cris','Ginez','32631563','987654321','cris_hater@gmail.com'),(5,'Jessica','Parra Bautista','23634231','975337264','jess.xd@gmail.com'),(6,'Jose Alberto','Quinones Miroquesada','74815956','987456159','j.quinones@gmail.com'),(7,'Omercito','Runco','12345678','741258963','omercitho123@gmail.com'),(8,'Omercito','Runco Valdez','74123695','123456789','omercitho123@gmail.com'),(9,'dsa','dsa','77777777','999999999','sad@hotmail.com'),(10,'Ruben','ASDASF','70096372','999999999','sb-690jj33634180@personal.example.com'),(11,'Rubendas','ASDASF','70096376','999999994','sb-690jj33634180@personal.example.com'),(12,'dsa','dsa','70096372','999999999','sad@hotmail.com'),(13,'hola','dsa','70096342','999999999','sad@hotmail.com'),(14,'dsa','dsa','74922216','999999999','sad@hotmail.com'),(15,'Roy','Makay','74922216','999999994','sb-690jj33634180@personal.example.com'),(16,'Roy','Makay','74922216','999999994','sb-690jj33634180@personal.example.com'),(17,'dsa','dsa','74922216','999999999','sad@hotmail.com'),(18,'Roy Makaay','Meza Taipe','74922216','951063543','U22205982@utp.edu.pe'),(19,'Roy Makaay','Meza Taipe','74922216','951063543','U22205982@utp.edu.pe');
/*!40000 ALTER TABLE `paciente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reserva`
--

DROP TABLE IF EXISTS `reserva`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reserva` (
  `idReserva` int NOT NULL AUTO_INCREMENT,
  `DiaReserva` date NOT NULL,
  `HoraReserva` time NOT NULL,
  `Descripcion` text NOT NULL,
  `Importe` decimal(10,2) NOT NULL,
  `FechaHoraPago` datetime NOT NULL,
  `Usuario_idUsuario` int NOT NULL,
  `Paciente_idPaciente` int NOT NULL,
  `Estado_idEstado` int NOT NULL,
  `Servicio_idServicio` int NOT NULL,
  `Odontologo_idUsuario` int NOT NULL,
  `dia_semana` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`idReserva`),
  KEY `fk_Reserva_Usuario1_idx` (`Usuario_idUsuario`),
  KEY `fk_Reserva_Paciente1_idx` (`Paciente_idPaciente`),
  KEY `fk_Reserva_Estado1_idx` (`Estado_idEstado`),
  KEY `fk_Reserva_Servicio1_idx` (`Servicio_idServicio`),
  KEY `fk_Reserva_Usuario2_idx` (`Odontologo_idUsuario`),
  CONSTRAINT `fk_Reserva_Estado1` FOREIGN KEY (`Estado_idEstado`) REFERENCES `estado` (`idEstado`),
  CONSTRAINT `fk_Reserva_Paciente1` FOREIGN KEY (`Paciente_idPaciente`) REFERENCES `paciente` (`idPaciente`),
  CONSTRAINT `fk_Reserva_Servicio1` FOREIGN KEY (`Servicio_idServicio`) REFERENCES `servicio` (`idServicio`),
  CONSTRAINT `fk_Reserva_Usuario1` FOREIGN KEY (`Usuario_idUsuario`) REFERENCES `usuario` (`idUsuario`),
  CONSTRAINT `fk_Reserva_Usuario2` FOREIGN KEY (`Odontologo_idUsuario`) REFERENCES `usuario` (`idUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserva`
--

LOCK TABLES `reserva` WRITE;
/*!40000 ALTER TABLE `reserva` DISABLE KEYS */;
INSERT INTO `reserva` VALUES (12,'2024-12-07','14:00:00','Primera vez en el centro odontologico',40.00,'2024-09-29 09:30:00',2,1,2,1,4,'Miércoles'),(13,'2024-12-10','10:00:00','a',50.00,'2024-12-01 18:53:43',2,9,3,2,4,'Martes'),(21,'2024-12-19','10:45:00','El señor Roy vino a hacer su revisión de cada semana y pidió que el señor Rubén lo atienta por sus extensos años de experiencia.',50.00,'2024-12-06 08:03:02',2,19,3,2,4,NULL),(22,'2024-12-27','13:45:00','El señor Roy vino a hacer su revisión de cada semana y pidió que el señor Rubén lo atienta por sus extensos años de experiencia.',40.00,'2024-12-06 08:14:14',2,19,3,1,4,NULL),(23,'2024-12-27','16:45:00','El señor Roy vino a hacer su revisión de cada semana y pidió que el señor Rubén lo atienta por sus extensos años de experiencia.',50.00,'2024-12-06 08:15:15',2,19,1,2,4,NULL);
/*!40000 ALTER TABLE `reserva` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `idRol` int NOT NULL AUTO_INCREMENT,
  `TipoRol` varchar(20) NOT NULL,
  PRIMARY KEY (`idRol`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'Administrador'),(2,'Secretaria'),(3,'Odontologo');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicio`
--

DROP TABLE IF EXISTS `servicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicio` (
  `idServicio` int NOT NULL AUTO_INCREMENT,
  `TipoServicio` text NOT NULL,
  `Lema` text NOT NULL,
  `Descripcion` text NOT NULL,
  `Respuesta` text NOT NULL,
  `Costo` decimal(10,2) NOT NULL,
  `img` text NOT NULL,
  PRIMARY KEY (`idServicio`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicio`
--

LOCK TABLES `servicio` WRITE;
/*!40000 ALTER TABLE `servicio` DISABLE KEYS */;
INSERT INTO `servicio` VALUES (1,'Limpieza Dental','La limpieza dental profesional es crucial para eliminar las bacterias daÃÂ±inas que pueden causar enfermedades bucodentales, como la caries, la gingivitis y la periodontitis.','La limpieza dental, tambiÃÂ©n conocida como profilaxis dental, es uno de los tratamientos dentales mÃÂ¡s demandados. Este procedimiento se realiza con el objetivo de prevenir enfermedades bucales. Su finalidad es eliminar el sarro y las manchas acumuladas en los dientes. Aunque no debe confundirse con el blanqueamiento dental, ya que la limpieza dental no altera el color de los dientes. El principal objetivo de la limpieza dental es prevenir enfermedades, ademÃÂ¡s de eliminar manchas y placa de sarro. La limpieza bucal debe ser realizada por un profesional y es eficaz para cuidar dientes y encÃÂ­as. Sin embargo, no se debe olvidar la limpieza diaria, es decir, el cepillado de dientes, especialmente antes de dormir.','El sarro en nuestros dientes es peligroso para nuestra salud bucodental, pudiendo dar lugar a enfermedades periodontales. Alguno de ellos son Salud bucodental, Caries, PÃÂ©rdida de piezas dentales y EstÃÂ©tica. Tanto las limpiezas dentales rutinarias como las profundas son importantes para prevenir infecciones y pÃÂ©rdida de dientes causadas por enfermedades de las encÃÂ­as. Si ha pasado tiempo desde tu ÃÂºltima limpieza, no lo pospongas mÃÂ¡s. Reserva tu cita hoy.',40.00,'https://www.dentaldelaware.com/wp-content/uploads/2021/12/teeth-cleaning.jpg'),(2,'Ortodoncia','La ortodoncia es la rama de la odontologÃ­a que se encarga de los problemas de los dientes y la mandÃ­bula','La ortodoncia sirve para corregir defectos de posiciÃ³n de dientes y huesos relacionados con los mismos, para asÃ­ tener una correcta oclusiÃ³n o mordida, para que la boca tenga una correcta funcionalidad a la hora de masticar o incluso hablar. Por tanto, los beneficios de un tratamiento de ortodoncia son muchos, y si bien uno de ellos es la estÃ©tica y uno de los motivos por los que se ha convertido en un tratamiento muy demandado este es una consecuencia, pero no el fin de someterse a un tratamiento de ortodoncia. AdemÃ¡s, cuando los dientes no tienen una posiciÃ³n correcta, se apiÃ±an, etc, resultan mÃ¡s difÃ­ciles de limpiar, lo que puede conllevar a una peor salud dental, con la apariciÃ³n de caries, periodontitis o incluso dolores de cabeza, cuello, hombros y espalda, al estar forzando la musculatura del aparato masticador.','La respuesta a esa pregunta solo la puede dar el dentista tras realizar un diagnÃ³stico craneofacial, pero en los casos siguientes, hay probabilidades de que asÃ­ sea: Tener una maloclusiÃ³n dental, como por ejemplo una sobremordida, una mordida cruzada o una mordida abierta. Si la llamada \"lÃ­nea media\" (que divide a los dientes anteriores superiores) estÃ¡ desplazada, porque no se alinea con la de los dientes inferiores. Cuando existen espacios entre los dientes o diastemas. Si los dientes estÃ¡n apiÃ±ados o son asimÃ©tricos. Si hay dolor de la articulaciÃ³n temporomandibular. Si existe una discrepancia entre los maxilares.',50.00,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQd3mIOWBBl7dkSQLGH417t6dFMFgKv3xYTQ&s'),(3,'Cirugía Oral','La cirugía oral es una especialidad de la odontología que se encarga de tratar las enfermedades y lesiones.','La cirugía oral se ocupa del diagnóstico, tratamiento y prevención de las enfermedades quirúrgicas de la cavidad oral. Esto incluye procedimientos quirúrgicos en los dientes, mandíbulas, y tejidos blandos de la boca. Los procedimientos más comunes en cirugía oral incluyen la extracción de dientes impactados, la corrección de malformaciones mandibulares y el tratamiento de lesiones orales.','Es recomendable considerar la cirugía oral en los siguientes casos:\n	Dientes Impactados: Dientes que no han erupcionado correctamente y pueden causar dolor o infecciones.\n	Malformaciones Mandibulares: Problemas con la alineación de la mandíbula que pueden afectar la masticación y el habla.\n	Lesiones Orales: Tratamiento de lesiones o infecciones en la cavidad oral que requieren intervención quirúrgica.',250.00,'https://clinicaruizestrada.com/wp-content/uploads/2023/02/limpieza-dental-prevencion-problemas-boca.jpg'),(4,'Blanqueamiento Dental','El blanqueamiento dental es un tratamiento que nos permite aclarar el tono de los dientes para un resultado estético ideal.','El blanqueamiento dental es un tratamiento estético que busca aclarar el color de los dientes y eliminar manchas superficiales. Este procedimiento puede ser realizado en una clínica dental o con productos de uso doméstico recomendados por un dentista.\n\nDurante el tratamiento, se utilizan agentes blanqueadores que descomponen las manchas en los dientes, devolviéndoles un aspecto más blanco y brillante. Es importante destacar que el blanqueamiento dental no afecta la estructura del diente, sino solo su color.\n\nEl blanqueamiento puede ser una opción adecuada para quienes desean mejorar su sonrisa y eliminar manchas causadas por alimentos, bebidas o tabaco. Sin embargo, es fundamental consultar con un dentista para determinar si el blanqueamiento es adecuado para ti.','Si bien el blanqueamiento dental es un tratamiento estético y no esencial para la salud dental, no realizarlo cuando se desea mejorar la apariencia de los dientes puede resultar en la persistencia de manchas y un color dental desigual.\n\nManchas persistentes: Las manchas en los dientes pueden volverse más notorias con el tiempo si no se realiza el blanqueamiento.\nEstética: La falta de blanqueamiento puede afectar la estética de tu sonrisa y tu confianza personal.\nCuidado dental: No realizar el blanqueamiento no afectará la salud dental, pero sí puede afectar la apariencia.\nSi estás considerando el blanqueamiento dental, te recomendamos programar una consulta con tu dentista para discutir las mejores opciones para ti. ¡No esperes más para lograr la sonrisa que deseas!',100.00,'https://gacetadental.com/wp-content/uploads/2022/07/blanqueamiento-dental-casero.jpg'),(5,'Tratamiento de caries.','Protege tu sonrisa, trata las caries a tiempo','El tratamiento de caries es un procedimiento odontológico que tiene como objetivo eliminar la caries dental y restaurar la estructura afectada del diente. Las caries son áreas dañadas en el esmalte dental, que ocurren debido a la acción de ácidos producidos por las bacterias de la placa dental. Si no se tratan, las caries pueden causar dolor, infecciones más graves, e incluso la pérdida del diente','El tratamiento de caries comienza con la eliminación del tejido dental afectado por la caries. Una vez que se retira la parte dañada, el espacio vacío se rellena con materiales de restauración, como amalgama, resina compuesta o porcelana, dependiendo de la ubicación y el tamaño de la cavidad. El procedimiento es generalmente rápido y, si se realiza a tiempo, puede evitar complicaciones mayores como infecciones en la pulpa dental que requieran tratamientos más invasivos como una endodoncia.',80.00,'https://axiomaestudidental.com/wp-content/uploads/2018/12/caries-interdentales-que-son-tratamiento-como-detectarlas.jpg'),(6,'Prótesis dentales','Recupera tu sonrisa con nuestras prótesis dentales','Las prótesis dentales son dispositivos diseñados para reemplazar los dientes que han sido perdidos o extraídos. Pueden ser removibles o fijas, dependiendo de las necesidades del paciente y la recomendación del odontólogo. Este tratamiento ayuda no solo a mejorar la estética dental, sino también a restaurar la función masticatoria, lo que mejora la calidad de vida del paciente. Existen varios tipos de prótesis, como las completas, parciales, o las sobre implantes, todas diseñadas a medida.','Las prótesis dentales son una opción eficaz para aquellos que han perdido uno o más dientes debido a lesiones, caries o enfermedades periodontales. Dependiendo de las circunstancias, se pueden usar prótesis parciales (cuando faltan algunos dientes) o completas (cuando faltan todos los dientes). Las prótesis fijas, como los puentes o coronas, se cementan de manera permanente, mientras que las removibles pueden ser retiradas para su limpieza diaria. Es importante consultar con un especialista para determinar la mejor opción.',200.00,'https://www.clinicanoguerol.com/wp-content/uploads/2023/04/imagen-tipos-de-protesis.jpg'),(7,'Endodoncia','Salva tu diente con una endodoncia eficaz','La endodoncia, comúnmente conocida como tratamiento de conducto, es un procedimiento odontológico que se realiza cuando el nervio o la pulpa del diente se inflama o infecta debido a caries profundas, lesiones o fracturas. El tratamiento consiste en la extracción del tejido afectado dentro del diente, la limpieza y desinfección de los conductos radiculares, y el posterior sellado del espacio. Este procedimiento ayuda a salvar el diente que de otro modo tendría que ser extraído.','El tratamiento de endodoncia es la solución recomendada cuando la pulpa dental se ve comprometida. Durante el procedimiento, el odontólogo elimina el tejido dañado, limpia cuidadosamente el interior del diente, y lo sella con materiales específicos para evitar futuras infecciones. El procedimiento es indoloro gracias a la anestesia local y permite mantener el diente funcional y estéticamente intacto. Posterior a la endodoncia, es posible que se coloque una corona dental para proteger el diente a largo plazo.',100.00,'https://gacetadental.com/wp-content/uploads/2022/07/que-es-endodoncia.jpg'),(9,'Limpieza Dental 2.0','Tus dientes mÃ¡s limpios que nunca','gaa','Ofrecemos una amplia variedad de herramientas.',120.00,'https://bfesteticadental.com/wp-content/uploads/2017/06/Odontologia-Caracas-Venezuela-BF-Estetica-Dental-700x450.jpg');
/*!40000 ALTER TABLE `servicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `idUsuario` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `Apellido` varchar(50) NOT NULL,
  `DNI` char(8) NOT NULL,
  `Telefono` char(9) NOT NULL,
  `CorreoElectronico` varchar(100) NOT NULL,
  `Direccion` varchar(100) NOT NULL,
  `FechaNacimiento` date NOT NULL,
  `Clave` varchar(50) NOT NULL,
  `Rol_idRol` int NOT NULL,
  PRIMARY KEY (`idUsuario`),
  KEY `fk_Usuario_Rol_idx` (`Rol_idRol`),
  CONSTRAINT `fk_Usuario_Rol` FOREIGN KEY (`Rol_idRol`) REFERENCES `rol` (`idRol`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'Juan David','Fernández Gomez','48223344','987101222','ana.fernandez@artdent.com','Calle Lima 123','2000-09-30','123',1),(2,'Ethelvina Georgina','Soto Vergara','78223344','987115982','ethelvina.soto@artdent.com','Calle Pacasmayo 486','2004-09-30','1234',2),(4,'Ruben','Cuadros','70096374','999999999','a@sdakjn.com','a','2024-12-01','1234',3),(5,'Andrea','IPv5','75121424','912384007','ipv5@gmail.com','Cono este','2004-02-19','1234',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_horario`
--

DROP TABLE IF EXISTS `usuario_horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_horario` (
  `idUsuario_Horario` int NOT NULL AUTO_INCREMENT,
  `Usuario_idUsuario` int NOT NULL,
  `Horario_idHorario` int NOT NULL,
  PRIMARY KEY (`idUsuario_Horario`),
  KEY `fk_Usuario_Horario_Usuario1_idx` (`Usuario_idUsuario`),
  KEY `fk_Usuario_Horario_Horario1_idx` (`Horario_idHorario`),
  CONSTRAINT `fk_Usuario_Horario_Horario1` FOREIGN KEY (`Horario_idHorario`) REFERENCES `horario` (`idHorario`),
  CONSTRAINT `fk_Usuario_Horario_Usuario1` FOREIGN KEY (`Usuario_idUsuario`) REFERENCES `usuario` (`idUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_horario`
--

LOCK TABLES `usuario_horario` WRITE;
/*!40000 ALTER TABLE `usuario_horario` DISABLE KEYS */;
INSERT INTO `usuario_horario` VALUES (1,1,1),(2,1,2),(3,2,1),(4,2,2),(6,4,2),(7,4,1),(8,4,3),(9,4,4),(10,4,5);
/*!40000 ALTER TABLE `usuario_horario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_servicio`
--

DROP TABLE IF EXISTS `usuario_servicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_servicio` (
  `idUsuario` int NOT NULL,
  `idServicio` int NOT NULL,
  `Disponibilidad` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`idUsuario`,`idServicio`),
  KEY `idServicio` (`idServicio`),
  CONSTRAINT `usuario_servicio_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`),
  CONSTRAINT `usuario_servicio_ibfk_2` FOREIGN KEY (`idServicio`) REFERENCES `servicio` (`idServicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_servicio`
--

LOCK TABLES `usuario_servicio` WRITE;
/*!40000 ALTER TABLE `usuario_servicio` DISABLE KEYS */;
INSERT INTO `usuario_servicio` VALUES (4,1,1),(4,2,1),(4,3,1);
/*!40000 ALTER TABLE `usuario_servicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `idVenta` int NOT NULL AUTO_INCREMENT,
  `Importe` decimal(10,2) NOT NULL,
  `FechaHoraPago` datetime NOT NULL,
  `Cita_idCita` int NOT NULL,
  PRIMARY KEY (`idVenta`),
  KEY `fk_Venta_Cita1_idx` (`Cita_idCita`),
  CONSTRAINT `fk_Venta_Cita1` FOREIGN KEY (`Cita_idCita`) REFERENCES `cita` (`idCita`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (2,40.00,'2024-10-06 00:07:19',2),(3,40.00,'2024-10-06 19:18:18',3),(9,40.00,'2024-12-05 19:17:12',11);
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'db_artdent'
--

--
-- Dumping routines for database 'db_artdent'
--
/*!50003 DROP PROCEDURE IF EXISTS `ListarCitasPorDiaSemana` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ListarCitasPorDiaSemana`(IN diasemana VARCHAR(10), IN semanaActual INT)
BEGIN
    DECLARE fechaInicio DATE;
    DECLARE fechaFin DATE;

    -- Calcular la fecha de inicio y fin de la semana según el número de semana actual
    SET fechaInicio = DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL (semanaActual - WEEK(CURDATE(), 1)) WEEK);
    SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

    -- Crear una tabla temporal para almacenar las citas y la orden_row
    CREATE TEMPORARY TABLE IF NOT EXISTS TempCitas (
        idCita INT,
        DiaReserva DATE,
        HoraReserva TIME,
        NombrePaciente VARCHAR(100),
        ApellidoPaciente VARCHAR(100),
        EstadoReserva VARCHAR(50),
        TipoServicio VARCHAR(50),
        Costo decimal(10,2),
        NombreOdontologo VARCHAR(100),
        ApellidoOdontologo VARCHAR(100),
        orden_row INT,
        color CHAR(7)
    );

    -- Insertar las citas en la tabla temporal
    INSERT INTO TempCitas (idCita, DiaReserva, HoraReserva, NombrePaciente, ApellidoPaciente, 
                            EstadoReserva, TipoServicio, Costo, NombreOdontologo, ApellidoOdontologo, orden_row, color)
    SELECT  c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, s.Costo,
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo,
            CASE 
                WHEN TIME(c.HoraReserva) < TIME('08:00:00') THEN 0
                WHEN TIME(c.HoraReserva) = TIME('08:00:00') THEN 2
                ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(c.HoraReserva)) / 15)
            END AS orden_row,
            CONCAT('#', LPAD(FLOOR(RAND() * 16777215), 6, '0')) AS color
    FROM cita c
    INNER JOIN paciente u ON c.Paciente_idPaciente = u.idPaciente
    INNER JOIN estado e ON c.Estado_idEstado = e.idEstado
    INNER JOIN servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN usuario od ON c.Odontologo_idUsuario = od.idUsuario
    WHERE c.Estado_idEstado IN (3) 
      AND c.DiaReserva BETWEEN fechaInicio AND fechaFin
      AND DAYOFWEEK(c.DiaReserva) = CASE diasemana
            WHEN 'Domingo' THEN 1
            WHEN 'Lunes' THEN 2
            WHEN 'Martes' THEN 3
            WHEN 'Miércoles' THEN 4
            WHEN 'Jueves' THEN 5
            WHEN 'Viernes' THEN 6
            WHEN 'Sábado' THEN 7
        END;

    -- Seleccionar de la tabla temporal
    SELECT * FROM TempCitas;

    -- Eliminar la tabla temporal al final
    DROP TEMPORARY TABLE IF EXISTS TempCitas;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ListarCitasSemanaActual` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ListarCitasSemanaActual`(IN diasemana VARCHAR(10))
BEGIN
    DECLARE fechaInicio DATE;
    DECLARE fechaFin DATE;

    -- Obtener el primer día de la semana (lunes)
    SET fechaInicio = DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);
    -- Obtener el último día de la semana (domingo)
    SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

    -- Crear una tabla temporal para almacenar las citas y la orden_row
    CREATE TEMPORARY TABLE IF NOT EXISTS TempCitas (
        idCita INT,
        DiaReserva DATE,
        HoraReserva TIME,
        NombrePaciente VARCHAR(100),
        ApellidoPaciente VARCHAR(100),
        EstadoReserva VARCHAR(50),
        TipoServicio VARCHAR(50),
        NombreOdontologo VARCHAR(100),
        ApellidoOdontologo VARCHAR(100),
        orden_row INT,
        color CHAR(7)
    );

    -- Insertar las citas en la tabla temporal
    INSERT INTO TempCitas (idCita, DiaReserva, HoraReserva, NombrePaciente, ApellidoPaciente, 
                            EstadoReserva, TipoServicio, NombreOdontologo, ApellidoOdontologo, orden_row, color)
    SELECT  c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo,
            CASE 
                WHEN TIME(c.HoraReserva) < TIME('08:00:00') THEN 0
                WHEN TIME(c.HoraReserva) = TIME('08:00:00') THEN 2
                ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(c.HoraReserva)) / 15)
            END AS orden_row,
            CONCAT('#', LPAD(FLOOR(RAND() * 16777215), 6, '0')) AS color
    FROM cita c
    INNER JOIN paciente u ON c.Paciente_idPaciente = u.idPaciente
    INNER JOIN estado e ON c.Estado_idEstado = e.idEstado
    INNER JOIN servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN usuario od ON c.Odontologo_idUsuario = od.idUsuario
    WHERE c.Estado_idEstado IN (3) 
      AND c.DiaReserva BETWEEN fechaInicio AND fechaFin
      AND DAYOFWEEK(c.DiaReserva) = CASE diasemana
            WHEN 'Domingo' THEN 1
            WHEN 'Lunes' THEN 2
            WHEN 'Martes' THEN 3
            WHEN 'Miércoles' THEN 4
            WHEN 'Jueves' THEN 5
            WHEN 'Viernes' THEN 6
            WHEN 'Sábado' THEN 7
        END;  -- Cambia la comparación a DAYOFWEEK para asegurar que funcione

    -- Seleccionar de la tabla temporal
    SELECT * FROM TempCitas;

    -- Opcional: Eliminar la tabla temporal al final
    DROP TEMPORARY TABLE IF EXISTS TempCitas;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ListarReservasPorDiaSemana` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ListarReservasPorDiaSemana`(IN diasemana VARCHAR(10), IN semanaActual INT)
BEGIN
    DECLARE fechaInicio DATE;
    DECLARE fechaFin DATE;

    -- Calcular la fecha de inicio y fin de la semana según el número de semana actual
    SET fechaInicio = DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL (semanaActual - WEEK(CURDATE(), 1)) WEEK);
    SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

    -- Crear una tabla temporal para almacenar las reservas y la orden_row
    CREATE TEMPORARY TABLE IF NOT EXISTS TempReservas (
        idReserva INT,
        DiaReserva DATE,
        HoraReserva TIME,
        Descripcion VARCHAR(255),
        Importe DECIMAL(10,2),
        dia_semana VARCHAR(10),
        NombrePaciente VARCHAR(100),
        ApellidoPaciente VARCHAR(100),
        EstadoReserva VARCHAR(50),
        TipoServicio VARCHAR(50),
        NombreOdontologo VARCHAR(100),
        ApellidoOdontologo VARCHAR(100),
        orden_row INT,
        color CHAR(7)
    );

    -- Insertar las reservas en la tabla temporal
    INSERT INTO TempReservas (idReserva, DiaReserva, HoraReserva, Descripcion, Importe, dia_semana,
                               NombrePaciente, ApellidoPaciente, EstadoReserva, TipoServicio,
                               NombreOdontologo, ApellidoOdontologo, orden_row, color)
    SELECT  r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            r.dia_semana,
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo,
            CASE 
                WHEN TIME(r.HoraReserva) < TIME('08:00:00') THEN 0
                WHEN TIME(r.HoraReserva) = TIME('08:00:00') THEN 2
                ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(r.HoraReserva)) / 15)
            END AS orden_row,
            CONCAT('#', LPAD(FLOOR(RAND() * 16777215), 6, '0')) AS color
    FROM reserva r
    INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
    INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
    INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
    INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario
    WHERE r.Estado_idEstado IN (3) 
      AND r.dia_semana = diasemana 
      AND r.DiaReserva BETWEEN fechaInicio AND fechaFin;

    -- Seleccionar de la tabla temporal
    SELECT * FROM TempReservas;

    -- Eliminar la tabla temporal al final
    DROP TEMPORARY TABLE IF EXISTS TempReservas;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ListarReservasSemanaActual` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ListarReservasSemanaActual`(IN diasemana VARCHAR(10))
BEGIN
    DECLARE fechaInicio DATE;
    DECLARE fechaFin DATE;

    -- Obtener el primer día de la semana (lunes)
    SET fechaInicio = DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);
    -- Obtener el último día de la semana (domingo)
    SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

    -- Crear una tabla temporal para almacenar las reservas y la orden_row
    CREATE TEMPORARY TABLE IF NOT EXISTS TempReservas (
        idReserva INT,
        DiaReserva DATE,
        HoraReserva TIME,
        Descripcion VARCHAR(255),
        Importe DECIMAL(10,2),
        dia_semana VARCHAR(10),
        NombrePaciente VARCHAR(100),
        ApellidoPaciente VARCHAR(100),
        EstadoReserva VARCHAR(50),
        TipoServicio VARCHAR(50),
        NombreOdontologo VARCHAR(100),
        ApellidoOdontologo VARCHAR(100),
        orden_row INT,
        color CHAR(7)
    );

    -- Insertar las reservas en la tabla temporal
    INSERT INTO TempReservas (idReserva, DiaReserva, HoraReserva, Descripcion, Importe, dia_semana,
                               NombrePaciente, ApellidoPaciente, EstadoReserva, TipoServicio,
                               NombreOdontologo, ApellidoOdontologo, orden_row, color)
    SELECT  r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            r.dia_semana,
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo,
            CASE 
                WHEN TIME(r.HoraReserva) < TIME('08:00:00') THEN 0
                WHEN TIME(r.HoraReserva) = TIME('08:00:00') THEN 2
                ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(r.HoraReserva)) / 15)
            END AS orden_row,
            CONCAT('#', LPAD(FLOOR(RAND() * 16777215), 6, '0')) AS color  -- Generar color aleatorio en formato hexadecimal
    FROM reserva r
    INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
    INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
    INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
    INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario
    WHERE r.Estado_idEstado IN (3) 
      AND r.dia_semana = diasemana 
      AND r.DiaReserva BETWEEN fechaInicio AND fechaFin;

    -- Seleccionar de la tabla temporal
    SELECT * FROM TempReservas;

    -- Opcional: Eliminar la tabla temporal al final
    DROP TEMPORARY TABLE IF EXISTS TempReservas;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ps_ReprogramarCita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ps_ReprogramarCita`(
    IN p_idCita INT,
    IN p_nuevaFecha DATE,
    IN p_nuevaHora TIME
)
BEGIN
    -- Actualizar la fecha, hora y estado de la cita según el id de la cita
    UPDATE cita
    SET DiaReserva = p_nuevaFecha, 
        HoraReserva = p_nuevaHora,
        Estado_idEstado = 4  -- Cambia el estado a 4
    WHERE idCita = p_idCita;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ps_ReprogramarReserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ps_ReprogramarReserva`(
    IN p_idReserva INT,
    IN p_nuevaFecha DATE,
    IN p_nuevaHora TIME
)
BEGIN
    UPDATE reserva
    SET DiaReserva = p_nuevaFecha, HoraReserva = p_nuevaHora,
		Estado_idEstado = 4 
    WHERE idReserva = p_idReserva;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_actualizarServicio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizarServicio`(
    IN p_idServicio INT,
    IN p_TipoServicio TEXT,
    IN p_Lema TEXT,
    IN p_Descripcion TEXT,
    IN p_Respuesta TEXT,
    IN p_Costo DECIMAL(10,2),
    IN p_img TEXT
)
BEGIN
    UPDATE servicio
    SET TipoServicio = p_TipoServicio,
        Lema = p_Lema,
        Descripcion = p_Descripcion,
        Respuesta = p_Respuesta,
        Costo = p_Costo,
        img = p_img
    WHERE idServicio = p_idServicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_actualizarUsuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizarUsuario`(
    IN p_idUsuario INT,
    IN p_Nombre VARCHAR(255),
    IN p_Apellido VARCHAR(255),
    IN p_Dni INT,
    IN p_Telefono VARCHAR(20),
    IN p_CorreoElectronico VARCHAR(255),
    IN p_Direccion VARCHAR(255),
    IN p_FechaNacimiento DATE,
    IN p_Clave VARCHAR(255),
    IN p_Rol_idRol INT
)
BEGIN
    UPDATE Usuario
    SET Nombre = p_Nombre,
        Apellido = p_Apellido,
        Dni = p_Dni,
        Telefono = p_Telefono,
        CorreoElectronico = p_CorreoElectronico,
        Direccion = p_Direccion,
        FechaNacimiento = p_FechaNacimiento,
        Clave = p_Clave,
        Rol_idRol = p_Rol_idRol
    WHERE idUsuario = p_idUsuario;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crearreserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crearreserva`(
    IN p_DiaReserva DATE,
    IN p_HoraReserva TIME,
    IN p_Descripcion TEXT,
    IN p_Importe DECIMAL(10,2),
    IN p_Usuario_idUsuario INT,
    IN p_Estado_idEstado INT,
    IN p_Servicio_idServicio INT,
    IN p_Odontologo_idUsuario INT
)
BEGIN
    DECLARE v_MaxPacienteID INT;
    
    -- Obtener el máximo idPaciente
    SELECT MAX(idPaciente) INTO v_MaxPacienteID
    FROM paciente;

    -- Insertar los datos en la tabla reserva
    INSERT INTO reserva (
        DiaReserva, 
        HoraReserva, 
        Descripcion, 
        Importe, 
        FechaHoraPago, 
        Usuario_idUsuario, 
        Paciente_idPaciente, 
        Estado_idEstado, 
        Servicio_idServicio, 
        Odontologo_idUsuario
    )
    VALUES (
        p_DiaReserva, 
        p_HoraReserva, 
        p_Descripcion, 
        p_Importe, 
        NOW(), 
        p_Usuario_idUsuario, 
        v_MaxPacienteID,  -- Usar el valor máximo de idPaciente
        p_Estado_idEstado, 
        p_Servicio_idServicio, 
        p_Odontologo_idUsuario
    );

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_DetalleCita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DetalleCita`(
    IN p_idCita INT
)
BEGIN
        SELECT 
            c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado,
            u.Nombre as NombreOdontologo,
            u.Apellido as ApellidoOdontologo
        FROM 
            cita c
        INNER JOIN 
            servicio s ON c.Servicio_idServicio = s.idServicio
        INNER JOIN 
            paciente p ON c.Paciente_idPaciente = p.idPaciente
        INNER JOIN 
            estado e ON c.Estado_idEstado = e.idEstado
		INNER JOIN 
			usuario u on c.Odontologo_idUsuario = u.idUsuario
        WHERE 
            c.idCita = p_idCita;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_DetalleReserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DetalleReserva`(
    IN p_idReserva INT
)
BEGIN
    SELECT 
        r.idReserva, 
        r.DiaReserva, 
        r.HoraReserva, 
        r.Descripcion, 
        r.Importe, 
        u.Nombre AS NombrePaciente, 
        u.Apellido AS ApellidoPaciente, 
        e.TipoEstado AS EstadoReserva, 
        s.TipoServicio, 
        od.Nombre AS NombreOdontologo, 
        od.Apellido AS ApellidoOdontologo
    FROM reserva r
    INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
    INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
    INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
    INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
    WHERE r.idReserva = p_idReserva;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_eliminarServicio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminarServicio`(IN p_idServicio INT)
BEGIN
    DELETE FROM servicio WHERE idServicio = p_idServicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_eliminarUsuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminarUsuario`(IN pIdUsuario INT)
BEGIN
	DELETE FROM venta WHERE Cita_idCita IN (Select idCita from cita where Odontologo_idUsuario = pIdUsuario);
	DELETE FROM cita WHERE Odontologo_idUsuario = pIdUsuario;
	DELETE FROM reserva WHERE Odontologo_idUsuario = pIdUsuario;
	DELETE FROM usuario_horario WHERE Usuario_idUsuario = pIdUsuario;
    DELETE FROM usuario_servicio WHERE idUsuario = pIdUsuario;
    DELETE FROM usuario WHERE idUsuario = pIdUsuario;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_iniciosesion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_iniciosesion`(IN i_DNI VARCHAR(100), IN i_clave VARCHAR(100))
BEGIN
select 
    u.idUsuario, u.Nombre, u.Apellido, u.DNI, r.TipoRol 
    from usuario u INNER JOIN rol r 
    ON u.Rol_idRol = r.idRol 
    WHERE u.DNI = i_DNI AND u.Clave = i_clave;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertarServicio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertarServicio`(
    IN p_TipoServicio TEXT,
    IN p_Lema TEXT,
    IN p_Descripcion TEXT,
    IN p_Respuesta TEXT,
    IN p_Costo DECIMAL(10,2),
    IN p_img TEXT
)
BEGIN
    INSERT INTO servicio (TipoServicio, Lema, Descripcion, Respuesta, Costo, img)
    VALUES (p_TipoServicio, p_Lema, p_Descripcion, p_Respuesta, p_Costo, p_img);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertarUsuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertarUsuario`(
    IN pNombre VARCHAR(50), 
    IN pApellido VARCHAR(50), 
    IN pDNI CHAR(8),
    IN pTelefono CHAR(9), 
    IN pCorreo VARCHAR(100), 
    IN pDireccion VARCHAR(100), 
    IN pFechaNacimiento DATE, 
    IN pClave VARCHAR(50), 
    IN pRol INT
)
BEGIN
    INSERT INTO usuario (Nombre, Apellido, DNI, Telefono, CorreoElectronico, Direccion, FechaNacimiento, Clave, Rol_idRol)
    VALUES (pNombre, pApellido, pDNI, pTelefono, pCorreo, pDireccion, pFechaNacimiento, pClave, pRol);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarCitasPorUsuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarCitasPorUsuario`(
    IN p_idUsuario INT
)
BEGIN
    DECLARE p_idRol INT;
    
    -- Obtener el rol del usuario
    SELECT Rol_idRol INTO p_idRol
    FROM usuario
    WHERE idUsuario = p_idUsuario;

    -- Si el usuario es secregtarop (p_idRol = 2)
    IF p_idRol = 2 or 1 THEN
        SELECT 
            c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado
        FROM 
            cita c
        INNER JOIN 
            servicio s ON c.Servicio_idServicio = s.idServicio
        INNER JOIN 
            paciente p ON c.Paciente_idPaciente = p.idPaciente
        INNER JOIN 
            estado e ON c.Estado_idEstado = e.idEstado
        WHERE 
            e.idEstado IN (1, 3, 4)  -- Mostrar solo citas con idEstado = 1 o 3
        ORDER BY 
            c.DiaReserva, c.HoraReserva;

    -- Si el usuario es odontólogo (p_idRol = 3)
    ELSEIF p_idRol = 3 THEN
        SELECT 
            c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado
        FROM 
            cita c
        INNER JOIN 
            servicio s ON c.Servicio_idServicio = s.idServicio
        INNER JOIN 
            paciente p ON c.Paciente_idPaciente = p.idPaciente
        INNER JOIN 
            estado e ON c.Estado_idEstado = e.idEstado
        WHERE 
             e.idEstado IN (1, 3, 4)  -- Mostrar solo citas con idEstado = 1 o 3
        ORDER BY 
            c.DiaReserva, c.HoraReserva;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listarCitasRecientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listarCitasRecientes`()
BEGIN
    SELECT 
        c.idCita,
        c.DiaReserva,
        c.HoraReserva,
        CONCAT(p.Nombre, ' ', p.Apellido) AS NombrePaciente,
        s.TipoServicio AS NombreServicio,
        e.TipoEstado AS EstadoNombre
    FROM 
        cita c
    INNER JOIN 
        paciente p ON c.Paciente_idPaciente = p.idPaciente
    INNER JOIN 
        servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN 
        estado e ON c.Estado_idEstado = e.idEstado
    ORDER BY 
        c.DiaReserva DESC, c.HoraReserva DESC
    LIMIT 10;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarHisotialCitas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarHisotialCitas`(
    IN p_idUsuario INT
)
BEGIN
    DECLARE p_idRol INT;
    
    -- Obtener el rol del usuario
    SELECT Rol_idRol INTO p_idRol
    FROM usuario
    WHERE idUsuario = p_idUsuario;

    -- Si el usuario es paciente (p_idRol = 2)
    IF p_idRol = 2 THEN
        SELECT 
            c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado
        FROM 
            cita c
        INNER JOIN 
            servicio s ON c.Servicio_idServicio = s.idServicio
        INNER JOIN 
            paciente p ON c.Paciente_idPaciente = p.idPaciente
        INNER JOIN 
            estado e ON c.Estado_idEstado = e.idEstado
        WHERE 
            e.idEstado IN (2)  
        ORDER BY 
            c.DiaReserva, c.HoraReserva;

    -- Si el usuario es odontólogo (p_idRol = 3)
    ELSEIF p_idRol = 3 THEN
        SELECT 
            c.idCita, 
            c.DiaReserva, 
            c.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado
        FROM 
            cita c
        INNER JOIN 
            servicio s ON c.Servicio_idServicio = s.idServicio
        INNER JOIN 
            paciente p ON c.Paciente_idPaciente = p.idPaciente
        INNER JOIN 
            estado e ON c.Estado_idEstado = e.idEstado
        WHERE 
             e.idEstado IN (2)  
        ORDER BY 
            c.DiaReserva, c.HoraReserva;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarHistorialReservas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarHistorialReservas`(
    IN p_idUsuario INT
)
BEGIN
    DECLARE p_idRol INT;
    
    -- Obtener el rol del usuario
    SELECT Rol_idRol INTO p_idRol
    FROM usuario
    WHERE idUsuario = p_idUsuario;

    -- Si el usuario es paciente (p_idRol = 2)
    IF p_idRol = 2 or p_idRol = 1 THEN
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE r.Estado_idEstado IN (2)  -- Mostrar solo reservas con idEstado = 1
        ORDER BY r.DiaReserva, r.HoraReserva;

    -- Si el usuario es odontólogo (p_idRol = 3)
    ELSEIF p_idRol = 3 THEN
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario
        WHERE r.Odontologo_idUsuario = p_idUsuario  -- Solo las reservas del odontólogo
        AND r.Estado_idEstado IN (2) 
        ORDER BY r.DiaReserva, r.HoraReserva;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarReservasPorUsuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarReservasPorUsuario`(
    IN p_idUsuario INT
)
BEGIN
    DECLARE p_idRol INT;
    
    -- Obtener el rol del usuario
    SELECT Rol_idRol INTO p_idRol
    FROM usuario
    WHERE idUsuario = p_idUsuario;

    -- Si el usuario es paciente (p_idRol = 2)
    IF p_idRol = 2 or p_idRol = 1 THEN
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE r.Estado_idEstado IN (1,3,4)  -- Mostrar solo reservas con idEstado = 1
        ORDER BY r.DiaReserva, r.HoraReserva;

    -- Si el usuario es odontólogo (p_idRol = 3)
    ELSEIF p_idRol = 3 THEN
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario
        WHERE r.Odontologo_idUsuario = p_idUsuario  -- Solo las reservas del odontólogo
        AND r.Estado_idEstado IN (1,3,4)  -- Mostrar solo reservas con idEstado = 1
        ORDER BY r.DiaReserva, r.HoraReserva;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listarReservasRecientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listarReservasRecientes`()
BEGIN
    SELECT 
        r.idReserva,
        r.DiaReserva,
        r.HoraReserva,
        CONCAT(p.Nombre, ' ', p.Apellido) AS NombrePaciente,
        s.TipoServicio AS NombreServicio,
        e.TipoEstado AS EstadoNombre
    FROM 
        reserva r
    INNER JOIN 
        paciente p ON r.Paciente_idPaciente = p.idPaciente
    INNER JOIN 
        servicio s ON r.Servicio_idServicio = s.idServicio
    INNER JOIN 
        estado e ON r.Estado_idEstado = e.idEstado
    ORDER BY 
        r.DiaReserva DESC, r.HoraReserva DESC
    LIMIT 10;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarReservasReporte` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarReservasReporte`(
    IN p_idUsuario INT
)
BEGIN
    DECLARE p_idRol INT;

    -- Obtener el rol del usuario
    SELECT Rol_idRol INTO p_idRol
    FROM usuario
    WHERE idUsuario = p_idUsuario;

    -- Si el usuario es paciente (p_idRol = 2)
    IF p_idRol = 2 or p_idRol = 1 THEN
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE r.Estado_idEstado IN (1,2,3,4,5)  -- Mostrar solo reservas con idEstado = 1
        ORDER BY r.DiaReserva, r.HoraReserva;

    -- Si el usuario es odontólogo (p_idRol = 3)
    ELSEIF p_idRol = 3 THEN
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario
        WHERE r.Odontologo_idUsuario = p_idUsuario  -- Solo las reservas del odontólogo
        AND r.Estado_idEstado IN (1,2,3,4,5)  -- Mostrar solo reservas con idEstado = 1
        ORDER BY r.DiaReserva, r.HoraReserva;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarReservasReporteAd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarReservasReporteAd`(
)
BEGIN

    -- Si el usuario es paciente (p_idRol = 2)
        SELECT 
            r.idReserva, 
            r.DiaReserva, 
            r.HoraReserva, 
            r.Descripcion, 
            r.Importe, 
            u.Nombre AS NombrePaciente, 
            u.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS EstadoReserva, 
            s.TipoServicio, 
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM reserva r
        INNER JOIN usuario u ON r.Usuario_idUsuario = u.idUsuario
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE r.Estado_idEstado IN (1,2,3,4,5)  -- Mostrar solo reservas con idEstado = 1
        ORDER BY r.DiaReserva, r.HoraReserva;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listarservicios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listarservicios`()
BEGIN
select * from servicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarTodasCitas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarTodasCitas`(
    IN p_idUsuario INT
)
BEGIN
    DECLARE p_idRol INT;

    -- Obtener el rol del usuario
    SELECT Rol_idRol INTO p_idRol
    FROM usuario
    WHERE idUsuario = p_idUsuario;

    -- Si el usuario es paciente (p_idRol = 2)
    IF p_idRol = 2 THEN
        SELECT 
            r.idCita, 
            r.DiaReserva, 
            r.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado,
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM 
            cita r
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN paciente p ON r.Paciente_idPaciente = p.idPaciente
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE e.idEstado IN (1, 2, 3, 4, 5)  
        ORDER BY r.DiaReserva, r.HoraReserva;

    -- Si el usuario es odontólogo (p_idRol = 3)
    ELSEIF p_idRol = 3 THEN
        SELECT 
            r.idCita, 
            r.DiaReserva, 
            r.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado,
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM 
            cita r
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN paciente p ON r.Paciente_idPaciente = p.idPaciente
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE e.idEstado IN (1, 2, 3, 4, 5)  
        ORDER BY r.DiaReserva, r.HoraReserva;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ListarTodasCitasAd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListarTodasCitasAd`(
)
BEGIN
        SELECT 
            r.idCita, 
            r.DiaReserva, 
            r.HoraReserva, 
            s.TipoServicio, 
            p.Nombre AS NombrePaciente, 
            p.Apellido AS ApellidoPaciente, 
            e.TipoEstado AS Estado,
            od.Nombre AS NombreOdontologo, 
            od.Apellido AS ApellidoOdontologo
        FROM 
            cita r
        INNER JOIN servicio s ON r.Servicio_idServicio = s.idServicio
        INNER JOIN paciente p ON r.Paciente_idPaciente = p.idPaciente
        INNER JOIN estado e ON r.Estado_idEstado = e.idEstado
        INNER JOIN usuario od ON r.Odontologo_idUsuario = od.idUsuario  -- Información del odontólogo
        WHERE e.idEstado IN (1, 2, 3, 4, 5)  
        ORDER BY r.DiaReserva, r.HoraReserva;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listarUsuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listarUsuarios`()
BEGIN
    SELECT *, r.TipoRol as RolN 
    FROM usuario as u inner join rol r on u.Rol_idRol = r.idRol;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtenerMedicosPorServicioYDisponibilidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtenerMedicosPorServicioYDisponibilidad`(
    IN p_idServicio INT,
    IN p_fecha DATE,
    IN p_hora TIME
)
BEGIN
    SELECT u.* 
    FROM usuario u
    JOIN medico_servicio ms ON u.idUsuario = ms.idMedico
    LEFT JOIN cita c ON u.idUsuario = c.idMedico AND c.fecha = p_fecha AND c.hora = p_hora
    WHERE ms.idServicio = p_idServicio
    AND u.Rol_idRol = 2 -- Asumiendo que 2 es el ID del rol de médico
    AND c.idCita IS NULL; -- Esto asegura que el médico no tenga una cita en esa fecha y hora
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtenerServicioPorId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtenerServicioPorId`(IN p_idServicio INT)
BEGIN
    SELECT * FROM servicio WHERE idServicio = p_idServicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtenerUsuarioPorId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtenerUsuarioPorId`(
in pIp int
)
BEGIN
    SELECT *, r.TipoRol as RolN 
    FROM usuario as u inner join rol r on u.Rol_idRol = r.idRol where idUsuario = pIp;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrarcita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrarcita`(
	IN p_dia_reserva 	DATE,
	IN p_hora_reserva 	TIME,
	IN p_id_servicio	INT,
	IN p_id_paciente 	CHAR(8),
	IN p_id_estado		INT,
    IN p_idOdontologo_idUsuario INT
)
BEGIN
	INSERT INTO cita (DiaReserva,HoraReserva,Servicio_idServicio,Paciente_idPaciente,Estado_idEstado,Odontologo_idUsuario) VALUES
		(p_dia_reserva,p_hora_reserva,p_id_servicio,p_id_paciente,p_id_estado,p_idOdontologo_idUsuario);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrarprimeracita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrarprimeracita`(
	IN p_diareserva DATE,
    IN p_horareserva TIME,
    IN p_idservicio INT,
    IN p_idestado INT,
    IN p_Odontologo_idUsuario INT
)
BEGIN
DECLARE lastPacienteId INT;
    SELECT idPaciente INTO lastPacienteId
    FROM paciente
    ORDER BY idPaciente DESC
    LIMIT 1;
    INSERT INTO cita (DiaReserva, HoraReserva, Servicio_idServicio, Paciente_idPaciente, Estado_idEstado, Odontologo_idUsuario)
    VALUES (p_diareserva, p_horareserva, p_idservicio, lastPacienteId, p_idestado,p_Odontologo_idUsuario);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrarusuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrarusuario`(
    IN p_Nombre VARCHAR(50),
    IN p_Apellido VARCHAR(50),
    IN p_DNI VARCHAR(8),
    IN p_Telefono VARCHAR(9),
    IN p_Correo VARCHAR(100))
BEGIN
 INSERT INTO paciente (Nombre, Apellido, DNI, Telefono, Correo)
    VALUES (p_Nombre, p_Apellido, p_DNI, p_Telefono, p_Correo);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ventas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ventas`(
	IN p_importe DECIMAL(10,2)
)
BEGIN
	DECLARE id_Cita INT;
    SELECT idCita INTO id_Cita 
    FROM cita
    ORDER BY idCita DESC
    LIMIT 1;
	INSERT INTO venta (Importe, FechaHoraPago, Cita_idCita) VALUES (p_importe, now(), id_Cita);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `verificarDisponibilidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `verificarDisponibilidad`(
    IN idUsuario INT, 
    IN fecha DATE, 
    IN hora TIME, 
    OUT disponible BOOLEAN
)
BEGIN
    DECLARE countReservas INT;
    SELECT COUNT(*) 
    INTO countReservas
    FROM Reserva 
    WHERE Usuario_idUsuario = idUsuario AND DiaReserva = fecha AND HoraReserva = hora;

    SET disponible = (countReservas = 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-06  9:26:19
