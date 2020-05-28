import random

import json
import math
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdifieldop import BDIFieldOp
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_action
from pygomas.ontology import HEALTH

from pygomas.agent import LONG_RECEIVE_WAIT


class AgenteDefensivo(BDIMedic):

    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

    @actions.add(".medicoMasCerca", 0)
    def _medico_mas_cercano(agent, term, intention):
        '''
        Recibe un parametro: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        # Lista de médicos que han respondido
        posiciones_agentes = 'parametro de entrada'
        # Posición del agente que solicita ayuda
        posicion_propia = agent.movement.position
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += math.sqrt(math.pow(
                posicion_agente[0] - posicion_propia.x, 2) + math.pow(posicion_agente[2] - posicion_propia.z, 2))

        # Ordenamos de menor a mayor
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un médico
        # Devolvemos la posicón del agente más cercano
        yield distancia_a_cada_agente.index(distancia_aux[0])