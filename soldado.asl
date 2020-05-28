//TEAM_AXIS (defensa)

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
  

// ESTRATEGIA DE RECEPCIÓN Y ENVIAMIENTO DE SOLICITUDES DE AYUDA DE SALUD
/* Creencia que dispara la estrategia */
+health(H): H < 20 & not solicitandoSalud
	<-
	+solicitandoSalud.

/* Difusion de solicitud de paquete de salud */
+myMedics(M): solicitandoSalud
	<-
	.print("Agente solicitando un paquete de vida.");
	?position(Pos);
	-+medicoPOS([]);
	-+medicoID([]);
	.send(M, tell, solicitudDeSalud(Pos));
	.wait(1000);
	!!elegirMedico;
	-myMedics(_).

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
	.nth(medico, Bi, Pos); // Esto no haria falta ¿?
	.nth(medico, Ag, A);
	.send(A, tell, solicitudAceptad);
	.delete(medico, Ag, Ag1);
	.send(Ag1, tell, solicitudDenegada);
	-+medicoPOS([]);
	-+medicoID([]);
	-solicitandoSalud.
	
/* Plan para cuando no hay ningún médico que me pueda ayudar */
+!elegirMedico: not (medicoPOS(Bi))
	<-
	.print("Ningún médico me puede ayudar.");
	-solicitandoSalud.