// SOLDADO EN DEFENSA (AXIS)

/* Creencia que se dispara cuando se inicia la partida */
+flag(F): team(200)
  <-
  !generarPatrulla.


/* ESTRATEGIA DE PATRULLA EN ROMBO (EXTERIOR) */
/* Generamos unos puntos de control en rombo */
+!generarPatrulla
	<-
	?flag(F);
	.circuloExterior(F, C);
	+control_points(C);
	.length(C, L);
	+total_control_points(L);
	+patrolling;
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
	.print("Agente solicitando un paquete de vida.");
	-+medicoPOS([]);
	-+medicoID([]);
	.get_service("general");
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
	.print("Agente solicitando un paquete de munición.");
	-+operativoPOS([]);
	-+operativoID([]);
	.get_service("general");
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudDeMunicion(Pos));
	.wait(1500).


	


/* ESTRATEGIA PARA IR EN COLMENA A POR UN ENEMIGO */
/* Visualizo un enemigo y no he avisado al General */	
+enemies_in_fov(_, _, _, _, _, Position): not colmena(_) & not atacando
	<-
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	// Mientras espera ordenes, ataca
	.look_at(Position);
    .shoot(3, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_));
	// Para no sobrecargar al General
	.wait(1000).

/* Visualizo un enemigo */
+enemies_in_fov(_, _, _, _, _, Position)
	<-
	.look_at(Position);
    .shoot(3, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_)).

/* El General me ha mandado la orden de atacar en colmena */
+colmena(Pos): not colmena(_) & not atacando
	<-
	// Eliminamos las creencias de patrulla
	-control_points(_);
	-total_control_points(_);
	-patrolling;
	-patroll_point(_);

	+atacando;
	.goto(Pos);
	-colmena(_).
	

/* Llego al objetivo del ataque en colmena */
+target_reached(Pos): atacando
	<-
	-atacando;
	// Volvemos a generar las coordenadas de la patrulla en rombo (por si se ha movido la bandera)
	.generarPatrulla.