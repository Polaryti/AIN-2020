//TEAM_AXIS

+flag (F): team(200) 
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points").


+target_reached(T): patrolling & team(200) 
  <-
  .print("AMMOPACK!");
  .reload;
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T 
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T
  <-
  -patroll_point(P);
  +patroll_point(0).



/* ESTRATEGIA DE PAQUETES DE SALUD */
/* Recibo solictud de ayuda */
+solicitudDeSalud(Pos)[source(A)]: not solicitandoSalud
	<-
  +solicitandoSalud;
  .myMedics(M);
	-+medicoPOS([]);
	-+medicoID([]);
	.send(M, tell, solicitudDeSalud(Pos));
	.wait(900);
  !!elegirMedico.


/* Concateno la posición y el ID de los médicos que responden */
+respuestaVida(Pos)[source(A)]: solicitandoSalud
	<-
	.print("Recibo propuesta.");
	?medicoPOS(B);
	.concat(B, [Pos], B1); -+medicoPOS(B1);
	?medicoID(Ag);
	.concat(Ag, [A], Ag1); -+medicoID(Ag1);
	-respuestaVida(Pos).
	

/* PLANES */
/* Plan para elegir el médico más cercano */
+!elegirMedico: medicoPOS(Bi) & medicoID(Ag)
	<-
	.print("Selecciono el mejor: ", Bi, Ag);
	.medicoMasCerca(Bi, medico);  // Guarda en medico la posición del medico elegido
	.nth(medico, Ag, A);
	.send(A, tell, solicitudAceptad);
	.delete(medico, Ag, Ag1);
	.send(Ag1, tell, solicitudDenegada);
	-+medicoPOS([]);
	-+medicoID([]);
	-solicitandoSalud.
	
/* Plan para cuando no hay ningún médico que pueda ayudar */
+!elegirMedico: not (medicoPOS(Bi))
	<-
	.print("Ningún médico puede ayudar.");
	-solicitandoSalud.
	



/* ESTRATEGIA DE PAQUETES DE MUNICIÓN */
/* Recibo solictud de ayuda */
+solicitudDeMunicion(Pos)[source(A)]: not solicitandoMunicion
	<-
  +solicitandoMunicion;
  .myFieldops(M);
	-+operativoPOS([]);
	-+operativoID([]);
	.send(M, tell, solicitudDeMunicion(Pos));
	.wait(900);
  !!elegirOperativo.


/* Concateno la posición y el ID de los operativos que responden */
+respuestaMunicion(Pos)[source(A)]: solicitandoMunicion
	<-
	.print("Recibo propuesta.");
	?operativoPOS(B);
	.concat(B, [Pos], B1); -+operativoPOS(B1);
	?operativoID(Ag);
	.concat(Ag, [A], Ag1); -+operativoID(Ag1);
	-respuestaMunicion(Pos).
	

/* PLANES */
/* Plan para elegir el operativo más cercano */
+!elegirOperativo: operativoPOS(Bi) & operativoID(Ag)
	<-
	.print("Selecciono el mejor: ", Bi, Ag);
	.operativoMasCerca(Bi, medico);  // Guarda en operativo la posición del operativo elegido
	.nth(operativo, Ag, A);
	.send(A, tell, solicitudAceptad);
	.delete(operativo, Ag, Ag1);
	.send(Ag1, tell, solicitudDenegada);
	-+operativoPOS([]);
	-+operativoID([]);
	-solicitandoMunicion.
	
/* Plan para cuando no hay ningún operativo que pueda ayudar */
+!elegirOperativo: not (operativoPOS(Bi))
	<-
	.print("Ningún operativo puede ayudar.");
	-solicitandoMunicion.
	
/*ESTRATEGIA ATACANTE LOCALIZADO*/
/*Recepción de la solicitude de instrucciones*/
+SolicitudeDeInstrucciones(Pos)[source(A)]: not solicitandoInstrucciones
	<-
	+D=[];
	/*Faltaria modificar agentes más cercanos para que devuelva */
	/*	sólo 1 o 2 personas de cada tipo*/
	+solicitandoInstrucciones;
	.get_medics
	?myMedics(M);
	.agentesMasCercanos(Pos,M,R);
	.concat(D,R,D);
	.get_fieldops;
	?myFieldops(F);
	.agentesMasCercanos(Pos,F,R);
	.concat(D,R,D);
	.get_backups;
	?myBackups(B);
	.agentesMasCercanos(Pos,B,R);
	.concat(D,R,D);
	.send(D,tell,Atacad(Pos));
	