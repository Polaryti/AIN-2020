import json
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdisoldier import BDISoldier
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions
from pygomas.ontology import HEALTH

from pygomas.agent import LONG_RECEIVE_WAIT

class BDIGeneral(BDISoldier):

    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

    @actions.add_function(".medicoMasCerca", (tuple,list, ))
    def _medico_mas_cercano(pos_sol, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_sol: Posicion de la unidad que solicita la ayuda.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''

        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += math.sqrt(math.pow(
                posicion_agente[0] - pos_sol.x, 2) + math.pow(posicion_agente[2] - pos_sol.z, 2))

        # Ordenamos de menor a mayor distanca Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un médico
        # Devolvemos la posicón del agente más cercano
        return distancia_a_cada_agente.index(distancia_aux[0])


    @actions.add_function(".operativoMasCerca", (tuple,list, ))
    def _operativo_mas_cercano(pos_sol, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_sol: Posicion de la unidad que solicita la ayuda.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += math.sqrt(math.pow(
                posicion_agente[0] - pos_sol.x, 2) + math.pow(posicion_agente[2] - pos_sol.z, 2))

        # Ordenamos de menor a mayor deistancia Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        return distancia_a_cada_agente.index(distancia_aux[0])


    @actions.add_function(".agentesMasCercanos1", (list, list, ))
    def _agentes_mas_cercanos1(pos_ene, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_ene: Posicion del agente enemigo detectado.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += math.sqrt(math.pow(
                posicion_agente[0] - pos_ene[0], 2) + math.pow(posicion_agente[2] - pos_ene[2], 2))

        # Ordenamos de menor a mayor distancia Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        res = []
        res += distancia_a_cada_agente.index(distancia_aux[0])

        return res

    @actions.add_function(".agentesMasCercanos2", (list, list, ))
    def _agentes_mas_cercanos2(pos_ene, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_ene: Posicion del agente enemigo detectado.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += math.sqrt(math.pow(
                posicion_agente[0] - pos_ene[0], 2) + math.pow(posicion_agente[2] - pos_ene[2], 2))

        # Ordenamos de menor a mayor distancia Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        res = []
        res += distancia_a_cada_agente.index(distancia_aux[0])
        res += distancia_a_cada_agente.index(distancia_aux[1])

        return res
        
    @actions.add_function(".distance", (tuple,tuple, ))
    def _distancia(p1, p2):
        return ((p1[0]-p2[0])**2+(p1[2]-p2[2])**2)**0.5
    
    '''
        Given Agent position and soldiers tuple, returns the best 
        attack pattern by the moment.
    '''
    @actions.add_function(".gpunto", (tuple,  ))
    def _gpunto(pos):     
        soldiers = self.soldiers_count
        target = []

        X,Z,Y = pos
        if Y - X > 0:
            X += 20
        else:
            X -= 20

        target = [X,Z,Y]
            
        # /** TODO **/
        return target
        



class SoldadoPropio(BDISoldier):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)
        
    @actions.add_function(".circuloInterior", (tuple))
    def _circuloInterior(posicion_bandera):
        '''
        Recibe un parametro: La posicición de la bandera.
        
        return: La lista de puntos de patrulla en circulo interior.
        '''
        # Distancia de creación del círculo
        distancia_de_circulo = 10

        punto_A = [posicion_bandera[0] - distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_B = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] - distancia_de_circulo]
        punto_C = [posicion_bandera[0] + distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_D = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] + distancia_de_circulo]

        return tuple([tuple(punto_A), tuple(punto_B), tuple(punto_C), tuple(punto_D)])


    @actions.add_function(".circuloExterior", (tuple))
    def _circulo_exterior(posicion_bandera):
        '''
        Recibe un parametro: La posicición de la bandera.
        
        return: La lista de puntos de patrulla en circulo exterior.
        '''
        # Distancia de creación del círculo
        distancia_de_circulo = 20

        punto_A = [posicion_bandera[0] - distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_B = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] - distancia_de_circulo]
        punto_C = [posicion_bandera[0] + distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_D = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] + distancia_de_circulo]

        return tuple([tuple(punto_A), tuple(punto_B), tuple(punto_C), tuple(punto_D)])