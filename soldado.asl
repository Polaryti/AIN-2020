/* Creencia que se dispara cuando se inicia la partida */
+flag(F): team(200)
  <-
  !generarPatrulla.

/* El agente gira mientras patrulla */
+rolling
	<-
	.turn(1);
	.wait(100);
	-+rolling.


/* ESTRATEGIA DE PATRULLA EN ROMBO (EXTERIOR) */
/* Generamos unos puntos de control en rombo */
+!generarPatrulla
	<-
	.print("Soldado empezando a patrullar.");
	?flag(F);
	.circuloExterior(F, Pini);
	.comprobarPuntos(Pini,C);
	+control_points(C);
	.length(C, L);
	+total_control_points(L);
	+patrolling;
	+rolling;
	+patroll_point(0).

+target_reached(T): patrolling & team(200)
  <-
  ?patroll_point(P);
  -+patroll_point(P + 1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P < T
  <-
  ?control_points(C);
  .nth(P, C, A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P == T
  <-
  -patroll_point(P);
  +patroll_point(0).
  

/* ESTRATEGIA DE PAQUETES DE SALUD */
/* Creencia que anula la estrategia */
+health(H): H >= 20 & solicitandoSalud
	<-
	-solicitandoSalud.

/* Creencia que dispara la estrategia */
+health(H): H < 20 & not solicitandoSalud
	<-
	+solicitandoSalud.

/* Solicitud al general */
+solicitandoSalud
	<-
	.print("Soldado solicitando paquete de salud.");
	-+medicoPOS([]);
	-+medicoID([]);
	.get_service("general");
	.wait(500);
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudDeSalud(Pos));
	.wait(1500).




/* ESTRATEGIA DE PAQUETES DE MUNICIÓN */
/* Creencia que anula la estrategia */
+ammo(A): A >= 20 & solicitandoMunicion
	<-
	-solicitandoMunicion.

/* Creencia que dispara la estrategia */
+ammo(A): A < 20 & not solicitandoMunicion
	<-
	+solicitandoMunicion.

/* Solicitud al general */
+solicitandoMunicion
	<-
	.print("Soldado solicitando paquete de munición.");
	-+operativoPOS([]);
	-+operativoID([]);
	.get_service("general");
	.wait(500);
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudDeMunicion(Pos));
	.wait(1500).


//* ESTRATEGIA PARA IR EN COLMENA A POR UN ENEMIGO */
/* Visualizo un enemigo y no he avisado al General */	
+enemies_in_fov(_, _, _, _, _, Position): not colmena(_) & not atacando
	<-
	.print("Soldado visualizando a un enemigo.")
	.get_service("general");
	.wait(500);
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	.abolish(enemies_in_fov(_,_,_,_,_,_));
	// Para no sobrecargar al General
	.wait(1000).

/* Visualizo un enemigo */
+enemies_in_fov(_, _, _, _, _, Position)
	<-
	.look_at(Position);
    .shoot(5, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_)).

// ¿Esto que hace si nunca se dispara?
/*
+objetivoLocalizado
	<-	
	.print("He visualizado al enemigo.");
	.get_service("general");
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	.look_at(Position);
    .shoot(3, Position);
	.wait(1000).
*/
	
+solicitudDeColmena(Pos)[source(A)]: not (ayudandoc(_))
	<-
	-print("Soldado recibiendo solicitud de colmena.");
	?position(MiPos);
	.send(A, tell, respuestaColmenaS(MiPos));
	+ayudandoc(Pos);
	-solicitudDeColmena(_).
	
/* Me aceptan la respuesta de solicitud de apoyo */
+solicitudAceptadaC[source(A)]: not solicitudAceptadaC(_) & not atacando
	<-
	.print("Soldado aceptando la solicitud de colmena.");
	-rolling;
	-control_points(_);
	-total_control_points(_);
	-patrolling;
	-patroll_point(_);
	+atacando;
	.goto(Pos);
	-solicitudAceptadaC(_).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegadaC[source(A)]: ayudandoc(Pos)
	<-
	.print("Soldado rechazando la solicitud de colmena.");
	-ayudandoc(Pos).
	
/* Llego al objetivo del ataque en colmena */
+target_reached(Pos): atacando
	<-
	.print("Soldado ha llegado a la ubicación del enemigo.");
	-atacando;
	!generarPatrulla.