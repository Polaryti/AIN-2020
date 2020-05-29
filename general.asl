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
+solicitudDeSalud(Pos)[source(A)]: not solicitandoAyuda
	<-
	+solicitandoAyuda;
	.myMedics(M);
	-+medicoPOS([]);
	-+medicoID([]);
	.send(M, tell, solicitudDeSalud(Pos));
	.wait(900);
	!!elegirMedico.


/* Concateno la posición y el ID de los médicos que responden */
+respuestaVida(Pos)[source(A)]: solicitandoAyuda
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
	-solicitandoAyuda.
	
/* Plan para cuando no hay ningún médico que pueda ayudar */
+!elegirMedico: not (medicoPOS(Bi))
	<-
	.print("Ningún médico puede ayudar.");
	-solicitandoAyuda.
	



/* ESTRATEGIA DE PAQUETES DE MUNICIÓN */
/* Recibo solictud de ayuda */
+solicitudDeMunicion(Pos)[source(A)]: not solicitandoAyuda
	<-
  +solicitandoAyuda;
  .myFieldops(M);
	-+operativoPOS([]);
	-+operativoID([]);
	.send(M, tell, solicitudDeMunicion(Pos));
	.wait(900);
  !!elegirOperativo.


/* Concateno la posición y el ID de los operativos que responden */
+respuestaMunicion(Pos)[source(A)]: solicitandoAyuda
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
	-solicitandoAyuda.
	
/* Plan para cuando no hay ningún operativo que pueda ayudar */
+!elegirOperativo: not (operativoPOS(Bi))
	<-
	.print("Ningún operativo puede ayudar.");
	-solicitandoAyuda.
	


/* ESTRATEGIA PARA IR EN COLMENA A POR UN ENEMIGO */
/*Recepción de la solicitude de instrucciones*/
+solicitudDeInstrucciones(Pos)[source(A)]: not solicitandoAyuda
	<-
	//+D=[]; <- ¿Que hace esto?
	/*	Faltaria modificar agentes más cercanos para que devuelva
		sólo 1 o 2 personas de cada tipo */
	+solicitandoAyuda;
	// Obtiene los médicos más cercanos
	// TODO: Comunicarse con los médicos y decirle al médico más cercano que vaya ("send(Medico, tell, colmena(Pos))")
	.get_medics;
	?myMedics(M);
	.agentesMasCercanos(Pos,M,R);
	.concat(D,R,D);
	// Obtiene los operativos más cercanos
	// TODO: Comunicarse con los operativos y decirle al operativo más cercano que vaya ("send(Operativo, tell, colmena(Pos))")
	.get_fieldops;
	?myFieldops(F);
	.agentesMasCercanos(Pos,F,R);
	.concat(D,R,D);
	// Obtiene los soldados más cercanos
	// TODO: Comunicarse con los soldados y decirle a los soldados más cercanos que vayan ("send(Soldados, tell, colmena(Pos))")
	.get_backups;
	?myBackups(B);
	.agentesMasCercanos(Pos,B,R);
	.concat(D,R,D);
	
	.send(D,tell, colmena(Pos));
	-solicitandoAyuda.


/*COLMENA*/

/*Recibe el aviso de que se ha localizado un enemigo(1 método)(Pos)*/
/*Pide las posiciones a los diferentes grupos de aliados*/

/*Recepción las posiciones de los diferentes grupos de aliados(3 métodos)*/

/*Calcula los aliados de cada grupo que están más cerca del posicion(Pos)(1método)*/

/*Comunica a los aliados más cercanos que deben ir a pos y comunica a los otros aliados que nada*/


/* Recibo solictud de apoyo */
+solicitudDeColmena(Pos)[source(A)]: not solicitandoAyuda
	<-
	+solicitandoAyuda;
	.get_medics;
	?myMedics(M);
	-+medicoPOS([]);
	-+medicoID([]);
	.send(M, tell, solicitudDeColmena(Pos));
	.get_fieldops;
	?myFieldops(F);
	-+operaPOS([]);
	-+operaID([]);
	.send(F, tell, solicitudDeColmena(Pos));
	.get_backups;
	?myBackups(S);
	-+soldadoPOS([]);
	-+soldadoID([]);
	.send(S, tell, solicitudDeColmena(Pos));
	.wait(900);
	!!elegirEquipo(Pos).


/* Concateno la posición y el ID de los médicos que responden */
+respuestaColmenaM(Pos)[source(A)]: solicitandoAyuda
	<-
	.print("Recibo propuesta.");
	?medicoPOS(B);
	.concat(B, [Pos], B1); -+medicoPOS(B1);
	?medicoID(Ag);
	.concat(Ag, [A], Ag1); -+medicoID(Ag1);
	-respuestaColmenaM(Pos).
	
/* Concateno la posición y el ID de los operativos que responden */
+respuestaColmenaF(Pos)[source(A)]: solicitandoAyuda
	<-
	.print("Recibo propuesta.");
	?operaPOS(B);
	.concat(B, [Pos], B1); -+operaPOS(B1);
	?operaID(Ag);
	.concat(Ag, [A], Ag1); -+operaID(Ag1);
	-respuestaColmenaF(Pos).

/* Concateno la posición y el ID de los soldados que responden */
+respuestaColmenaS(Pos)[source(A)]: solicitandoAyuda
	<-
	.print("Recibo propuesta.");
	?soldadoPOS(B);
	.concat(B, [Pos], B1); -+soldadoPOS(B1);
	?soldadoID(Ag);
	.concat(Ag, [A], Ag1); -+soldadoID(Ag1);
	-respuestaColmenaS(Pos).

/* PLANES */
/* Plan para elegir el médico más cercano */
+!elegirEquipo(Pos): 
	<-
	?medicoPOS(Ml);
	?medicoID(Mi);
	.agentesMasCercanos1(Pos, Ml, medico);  // Guarda en medico la posición del medico elegido
	.nth(medico, Mi, A);
	.send(A, tell, solicitudAceptadaC(Pos));
	.delete(medico, Mi, Ag1);
	.send(Ag1, tell, solicitudDenegadaC);
	-+medicoPOS([]);
	-+medicoID([]);
	
	?operaPOS(Fl);
	?operaID(Fi);
	.agentesMasCercanos1(Pos, Fl, fieldOp);  // Guarda en medico la posición del medico elegido
	.nth(fieldOp, Fi, A);
	.send(A, tell, solicitudAceptadaC(Pos));
	.delete(fieldOp, Fi, Ag1);
	.send(Ag1, tell, solicitudDenegadaC);
	-+operaPOS([]);
	-+operaID([]);
	
	?soldadoPOS(Sl);
	?soldadoID(Si);
	.agentesMasCercanos2(Pos, Sl, soldado);  // Guarda en medico la posición del medico elegido
	.nth(soldado, Si, A);
	.send(A, tell, solicitudAceptadaC(Pos));
	.delete(soldado, Si, Ag1);
	.send(Ag1, tell, solicitudDenegadaC);
	-+soldadoPOS([]);
	-+soldadoID([]);
	
	-solicitandoAyuda.
	
/* Plan para cuando no hay ningún médico que pueda ayudar */
+!elegirEquipo: 
	<-
	.print("Ningún médico puede ayudar.");
	-solicitandoAyuda.