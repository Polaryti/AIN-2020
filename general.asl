//TEAM_AXIS

+flag (F): team(200) 
  <-
  .register_service("general");
  .print("General se queda en la base.").

/* El agente gira */
+rolling
	<-
	.turn(1);
	.wait(100);
	-+rolling.

/* Visualizo un enemigo */
+enemies_in_fov(_, _, _, _, _, Position)
	<-
	.look_at(Position);
    .shoot(3, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_)).


/* ESTRATEGIA DE PAQUETES DE SALUD */
/* Recibo solictud de ayuda */
+solicitudDeSalud(Pos)[source(A)]: not solicitandoAyuda
	<-
	.print("General ha recibido una solicitud de vida.");
	+solicitandoAyuda;
	?myMedics(M);
	-+medicoPOS([]);
	-+medicoID([]);
	.send(M, tell, solicitudDeSalud(Pos));
	.wait(900);
	!!elegirMedico(Pos).


/* Concateno la posicion y el ID de los medicos que responden */
+respuestaVida(Pos)[source(A)]: solicitandoAyuda
	<-
	.print("General recibe respuesta de un medico.");
	.get_medics;
	?medicoPOS(B);
	.concat(B, [Pos], B1); -+medicoPOS(B1);
	?medicoID(Ag);
	.concat(Ag, [A], Ag1); -+medicoID(Ag1);
	-respuestaVida(Pos).
	

/* PLANES */
/* Plan para elegir el medico más cercano */
+!elegirMedico(Pos): medicoPOS(Bi) & medicoID(Ag)
	<-
	.print("Selecciono el mejor: ", Bi, Ag);
	?medicoPOS(Bi);
	?medicoID(Ag);
	.medicoMasCerca(Pos,Bi, Medico);  // Guarda en Medico la posicion del medico elegido
	.nth(Medico, Ag, A);
	.send(A, tell, solicitudAceptad);
	.delete(Medico, Ag, Ag1);
	.send(Ag1, tell, solicitudDenegada);
	-+medicoPOS([]);
	-+medicoID([]);
	-solicitandoAyuda.
	
/* Plan para cuando no hay ningún medico que pueda ayudar */
+!elegirMedico: not (medicoPOS(Bi))
	<-
	.print("General no ha recibido respuesta de ningun medico.");
	-solicitandoAyuda.
	



/* ESTRATEGIA DE PAQUETES DE MUNICION */
/* Recibo solictud de ayuda */
+solicitudDeMunicion(Pos)[source(A)]: not solicitandoAyuda
	<-
	.print("General ha recibido una solicitud de municion.");
  	+solicitandoAyuda;
  	.get_fieldops;
  	?myFieldops(M);
	-+operativoPOS([]);
	-+operativoID([]);
	.send(M, tell, solicitudDeMunicion(Pos));
	.wait(900);
 	!!elegirOperativo(Pos).


/* Concateno la posicion y el ID de los operativos que responden */
+respuestaMunicion(Pos)[source(A)]: solicitandoAyuda
	<-
	.print("General ha recibido una respuesta de operativo.");
	?operativoPOS(B);
	.concat(B, [Pos], B1); -+operativoPOS(B1);
	?operativoID(Ag);
	.concat(Ag, [A], Ag1); -+operativoID(Ag1);
	-respuestaMunicion(Pos).
	

/* PLANES */
/* Plan para elegir el operativo más cercano */
+!elegirOperativo(Pos): operativoPOS(Bi) & operativoID(Ag)
	<-
	.print("Selecciono el mejor: ", Bi, Ag);
	.operativoMasCerca(Pos, Bi, Operativo);  // Guarda en operativo la posicion del operativo elegido
	.nth(Operativo, Ag, A);
	.send(A, tell, solicitudAceptad);
	.delete(A, Ag, Ag1);
	.send(Ag1, tell, solicitudDenegada);
	-+operativoPOS([]);
	-+operativoID([]);
	-solicitandoAyuda.
	
/* Plan para cuando no hay ningun operativo que pueda ayudar */
+!elegirOperativo: not (operativoPOS(Bi))
	<-
	.print("Ningún operativo puede ayudar.");
	-solicitandoAyuda.
	


/* COLMENA */
/* Recibo solictud de apoyo */
+solicitudDeColmena(Pos)[source(A)]: not solicitandoAyuda
	<-
	.print("General ha recibido una solicitud de colmena.");
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
	.wait(800);
	!!elegirEquipo(Pos).


/* Concateno la posicion y el ID de los médicos que responden */
+respuestaColmenaM(Pos)[source(A)]: solicitandoAyuda
	<-
	?medicoPOS(B);
	.concat(B, [Pos], B1); -+medicoPOS(B1);
	?medicoID(Ag);
	.concat(Ag, [A], Ag1); -+medicoID(Ag1);
	-respuestaColmenaM(Pos).
	
/* Concateno la posicion y el ID de los operativos que responden */
+respuestaColmenaF(Pos)[source(A)]: solicitandoAyuda
	<-
	?operaPOS(B);
	.concat(B, [Pos], B1); -+operaPOS(B1);
	?operaID(Ag);
	.concat(Ag, [A], Ag1); -+operaID(Ag1);
	-respuestaColmenaF(Pos).

/* Concateno la posicipn y el ID de los soldados que responden */
+respuestaColmenaS(Pos)[source(A)]: solicitandoAyuda
	<-
	?soldadoPOS(B);
	.concat(B, [Pos], B1); -+soldadoPOS(B1);
	?soldadoID(Ag);
	.concat(Ag, [A], Ag1); -+soldadoID(Ag1);
	-respuestaColmenaS(Pos).

/* PLANES */
/* Plan para elegir la composición de colmena */
+!elegirEquipo(Pos) 
	<-
	?medicoPOS(Ml);
	?medicoID(Mi);
	.agentesMasCercanos1(Pos, Ml, Medico);  // Guarda en Medico la posición del medico elegido	
	.nth(0, Medico, AuxM);
	.nth(AuxM, Mi, A);
	.send(A, tell, solicitudAceptadaC(Pos));
	.delete(AuxM, Fi, Ag1);
	.send(Ag1, tell, solicitudDenegadaC);
	-+medicoPOS([]);
	-+medicoID([]);
	
	?operaPOS(Fl);
	?operaID(Fi);
	.agentesMasCercanos1(Pos, Fl, FieldOp);  // Guarda en FieldOp la posición del medico elegido
	.nth(0, FieldOp, AuxF);
	.nth(AuxF, Fi, A);
	.send(A, tell, solicitudAceptadaC(Pos));
	.delete(AuxF, Fi, Ag1);
	.send(Ag1, tell, solicitudDenegadaC);
	-+operaPOS([]);
	-+operaID([]);
	
	?soldadoPOS(Sl);
	?soldadoID(Si);
	.agentesMasCercanos2(Pos, Sl, Soldado);  // Guarda en Soldado la posición del medico elegido
	.nth(0, Soldado, Aux1);
	.nth(1, Soldado, Aux2);
	.nth(Aux1, Si, A);
	.nth(Aux1, Si, B);
	.send(A, tell, solicitudAceptadaC(Pos));
	.send(B, tell, solicitudAceptadaC(Pos));
	.delete(Aux1, Fi, Ag1);	
	.delete(Aux2, Fi, Ag1);
	.send(Ag1, tell, solicitudDenegadaC);
	-+soldadoPOS([]);
	-+soldadoID([]);
	
	-solicitandoAyuda.
	
/* Plan para cuando no hay ningún médico que pueda ayudar */
/*
+!elegirEquipo
	<-
	.print("La colmena no puede reunirse.");
	-solicitandoAyuda.
*/