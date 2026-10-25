#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Variables del jugador
player_name=""
player_race=""
player_class=""
player_hp=0
player_max_hp=0
player_atk=0
player_def=0
player_xp=0
player_level=1
player_potions=3
player_sword="Sin arma"
player_artifact="Ninguno"
player_gold=0

# Variables de estado
special_ability_used=false
fury_turns=0  # Para la habilidad del Guerrero

# Variables de la historia
enanos_aliados=false
elfos_aliados=false
humanos_aliados=false
vagabundo_ayudado=false
ciudad_explorada=false
cueva_explorada=false
pantano_explorado=false

# Función para mostrar el estado del jugador
show_status() {
    echo -e "${YELLOW}=============================================="
    echo " Estado de $player_name (Nivel $player_level)"
    echo "=============================================="
    echo -e "${NC}"
    echo -e "HP: ${GREEN}$player_hp/$player_max_hp${NC}"
    echo -e "ATK: ${RED}$player_atk${NC}"
    echo -e "DEF: ${BLUE}$player_def${NC}"
    echo -e "XP: $player_xp/100"
    echo -e "Pociones: $player_potions"
    echo -e "Oro: $player_gold"
    echo -e "Arma: $player_sword"
    echo -e "Artefacto: $player_artifact"
    echo -e "${YELLOW}=============================================="
    echo -e "${NC}"
}

# Función para subir de nivel
level_up() {
    if [[ $player_xp -ge 100 ]]; then
        player_level=$((player_level + 1))
        player_max_hp=$((player_max_hp + 20))
        player_hp=$player_max_hp
        player_atk=$((player_atk + 5))
        player_def=$((player_def + 3))
        player_xp=0
        echo -e "${GREEN}¡Has subido al nivel $player_level!${NC}"
        echo -e "HP: $player_hp, ATK: $player_atk, DEF: $player_def"
    fi
}

# Función de habilidades especiales
special_ability() {
    case $player_class in
        "Guerrero")
            if [[ $special_ability_used == false ]]; then
                echo -e "${RED}¡Furia Guerrera! (ATK doble por 2 turnos)${NC}"
                player_atk=$((player_atk * 2))
                special_ability_used=true
                fury_turns=2
            else
                echo -e "${RED}Habilidad especial ya usada en este combate${NC}"
            fi
            ;;
        "Arquero")
            echo -e "${GREEN}¡Disparo Preciso! (Ignora DEF enemiga)${NC}"
            enemy_def=0
            ;;
        "Mago")
            echo -e "${PURPLE}¡Bola de Fuego! (150% de daño)${NC}"
            player_atk=$((player_atk * 3 / 2))
            ;;
        "Asesino")
            echo -e "${RED}¡Ataque Sorpresa! (Doble daño este turno)${NC}"
            player_atk=$((player_atk * 2))
            special_ability_used=true
            ;;
        "Clérigo")
            echo -e "${GREEN}¡Cura Divina! (+50 HP)${NC}"
            player_hp=$((player_hp + 50))
            if [[ $player_hp -gt $player_max_hp ]]; then
                player_hp=$player_max_hp
            fi
            ;;
        "Dios")
            echo -e "${YELLOW}¡Poder Absoluto! (Derrota instantáneamente al enemigo)${NC}"
            enemy_hp=0
            ;;
        *)
            echo -e "${YELLOW}Habilidad especial no implementada${NC}"
            ;;
    esac
}

# Función de combate mejorada
combat() {
    enemy_name=$1
    enemy_hp=$2
    enemy_atk=$3
    enemy_def=$4
    special_ability_used=false
    fury_turns=0

    echo -e "${RED}¡Un $enemy_name aparece!${NC}"
    while [[ $player_hp -gt 0 && $enemy_hp -gt 0 ]]; do
        show_status
        echo -e "${YELLOW}$enemy_name - HP: $enemy_hp, ATK: $enemy_atk, DEF: $enemy_def${NC}"
        echo "Elige una acción:"
        echo "1. Atacar"
        echo "2. Defender"
        echo "3. Usar Poción"
        echo "4. Habilidad Especial"
        read -p "Selecciona una opción (1-4): " action

        case $action in
            1)
                # Cálculo de daño mejorado
                ignored_def=$((enemy_def / 5))  # Ignorar 20% de DEF
                effective_def=$((enemy_def - ignored_def))
                damage=$((player_atk - effective_def))

                # Ataque crítico (10% de probabilidad)
                if [[ $((RANDOM % 10)) -eq 0 ]]; then
                    damage=$((damage * 2))
                    echo -e "${PURPLE}¡Golpe crítico!${NC}"
                fi

                # Daño mínimo de 1
                if [[ $damage -lt 1 ]]; then
                    damage=1
                fi

                enemy_hp=$((enemy_hp - damage))
                echo -e "${GREEN}¡Atacas al $enemy_name y le haces $damage de daño!${NC}"
                ;;
            2)
                echo -e "${BLUE}Te defiendes. El próximo ataque del enemigo será menos efectivo.${NC}"
                player_def=$((player_def + 5))
                ;;
            3)
                if [[ $player_potions -gt 0 ]]; then
                    player_hp=$((player_hp + 30))
                    if [[ $player_hp -gt $player_max_hp ]]; then
                        player_hp=$player_max_hp
                    fi
                    player_potions=$((player_potions - 1))
                    echo -e "${GREEN}¡Usas una poción y recuperas 30 de salud!${NC}"
                else
                    echo -e "${RED}No tienes pociones disponibles.${NC}"
                fi
                ;;
            4)
                special_ability
                ;;
            *)
                echo "Opción inválida. Pierdes tu turno."
                ;;
        esac

        # Reducir contador de Furia Guerrera
        if [[ $fury_turns -gt 0 ]]; then
            fury_turns=$((fury_turns - 1))
            if [[ $fury_turns -eq 0 ]]; then
                player_atk=$((player_atk / 2))
                echo -e "${RED}La Furia Guerrera ha terminado. Tu ATK vuelve a la normalidad.${NC}"
            fi
        fi

        # Turno del enemigo
        if [[ $enemy_hp -gt 0 ]]; then
            damage=$((enemy_atk - player_def))
            if [[ $damage -lt 0 ]]; then
                damage=0
            fi
            player_hp=$((player_hp - damage))
            echo -e "${RED}¡El $enemy_name te ataca y te hace $damage de daño!${NC}"

            # Regeneración del enemigo (25% de probabilidad)
            if [[ $((RANDOM % 4)) -eq 0 ]]; then
                enemy_hp=$((enemy_hp + 10))
                echo -e "${RED}El $enemy_name regenera 10 de salud.${NC}"
            fi
        fi

        # Resetear defensa
        player_def=$((player_def - 5))
        [[ $player_def -lt 0 ]] && player_def=0
    done

    if [[ $player_hp -le 0 ]]; then
        echo -e "${RED}¡Has sido derrotado por el $enemy_name!${NC}"
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        exit 1
    else
        echo -e "${GREEN}¡Has derrotado al $enemy_name!${NC}"
        player_xp=$((player_xp + 160))
        player_gold=$((player_gold + 50))
        level_up
    fi
}




# Introducción
clear
echo -e "${YELLOW}=============================================="
echo " LA PROFECÍA DE BASH: LA GUERRA DE LOS REINOS"
echo "=============================================="
echo -e "${NC}"
read -p "Ingresa tu nombre: " player_name
echo -e "${GREEN}¡Bienvenido, $player_name!${NC}"
echo -e "${BLUE}Presiona Enter para continuar...${NC}"
read

# Selección de raza
clear
echo -e "${YELLOW}=============================================="
echo " Elige tu raza"
echo "=============================================="
echo -e "${NC}"
echo "1. Enano"
echo "2. Elfo"
echo "3. Humano"
echo "4. Dios"
read -p "Selecciona una opción (1-4): " race

case $race in
    1)
        player_race="Enano"
        player_max_hp=120
        player_hp=120
        player_atk=15
        player_def=20
        ;;
    2)
        player_race="Elfo"
        player_max_hp=100
        player_hp=100
        player_atk=25
        player_def=10
        ;;
    3)
        player_race="Humano"
        player_max_hp=110
        player_hp=110
        player_atk=20
        player_def=15
        ;;
    4)
        player_race="Dios"
        player_max_hp=999
        player_hp=999
        player_atk=999
        player_def=999
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

# Selección de especialidad
clear
echo -e "${YELLOW}=============================================="
echo " Elige tu especialidad"
echo "=============================================="
echo -e "${NC}"
echo "1. Guerrero"
echo "2. Arquero"
echo "3. Mago"
echo "4. Asesino"
echo "5. Clérigo"
echo "6. Dios"
read -p "Selecciona una opción (1-6): " class

case $class in
    1)
        player_class="Guerrero"
        player_max_hp=$((player_max_hp + 30))
        player_hp=$player_max_hp
        player_atk=$((player_atk + 10))
        player_sword="Espada Pesada"
        echo "Descripción: Tanque con alta resistencia y daño moderado."
        echo "Habilidad Especial: Furia Guerrera (Doble ATK durante 2 turnos)."
        ;;
    2)
        player_class="Arquero"
        player_max_hp=$((player_max_hp + 10))
        player_hp=$player_max_hp
        player_atk=$((player_atk + 20))
        player_sword="Arco Largo"
        echo "Descripción: Daño a distancia, ideal para ataques rápidos."
        echo "Habilidad Especial: Disparo Preciso (Ignora DEF enemiga)."
        ;;
    3)
        player_class="Mago"
        player_atk=$((player_atk + 25))
        player_def=$((player_def - 10))
        player_sword="Báculo Mágico"
        echo "Descripción: Poderoso en ataque, pero frágil."
        echo "Habilidad Especial: Bola de Fuego (Aumenta ATK en 50% durante 1 turno)."
        ;;
    4)
        player_class="Asesino"
        player_atk=$((player_atk + 30))
        player_def=$((player_def - 15))
        player_sword="Dagas Gemelas"
        echo "Descripción: Daño crítico alto, pero muy frágil."
        echo "Habilidad Especial: Ataque Sorpresa (Doble daño en el primer turno)."
        ;;
    5)
        player_class="Clérigo"
        player_max_hp=$((player_max_hp + 40))
        player_hp=$player_max_hp
        player_atk=$((player_atk + 5))
        player_def=$((player_def + 10))
        player_sword="Símbolo Sagrado"
        echo "Descripción: Soporte con alta resistencia y habilidades curativas."
        echo "Habilidad Especial: Cura Divina (Cura 50 HP)."
        ;;
    6)
        player_class="Dios"
        player_max_hp=999
        player_hp=999
        player_atk=999
        player_def=999
        player_sword="Gracia Divina"
        echo "Descripción: Invencible, solo para pruebas o diversión."
        echo "Habilidad Especial: Poder Absoluto (Derrota instantáneamente al enemigo)."
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

echo -e "${GREEN}Has elegido la raza: $player_race y la especialidad: $player_class${NC}"
echo -e "HP: $player_hp, ATK: $player_atk, DEF: $player_def"
echo -e "${BLUE}Presiona Enter para comenzar tu aventura...${NC}"
read

# Prólogo: El Llamado del Destino
clear
echo -e "${YELLOW}=============================================="
echo " Prólogo: El Llamado del Destino"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}En un mundo donde los reinos de Eredrim están al borde del colapso, una antigua profecía emerge de las sombras.${NC}"
echo -e "${BLUE}Habla de un héroe destinado a unir a las razas divididas y enfrentarse a un mal ancestral que amenaza con devorar todo lo que conocemos.${NC}"
echo -e "${BLUE}Este héroe no es un guerrero legendario, ni un mago de renombre, sino un elegido por el destino: tú, $player_name.${NC}"
echo -e "${BLUE}El Bash, una fuerza mística que gobierna el equilibrio del mundo, te ha elegido para cumplir una misión imposible.${NC}"
echo -e "${BLUE}Reunirás a los Enanos de las Montañas de Hierro, a los Elfos del Bosque Eterno y a los Humanos de las Llanuras del Amanecer.${NC}"
echo -e "${BLUE}Juntos, enfrentarán al Dragón de las Sombras, una criatura que ha despertado de su letargo milenario.${NC}"
echo -e "${BLUE}Tu viaje comienza ahora.${NC}"
echo -e "${BLUE}Presiona Enter para continuar...${NC}"
read

# Capítulo 1: Las Montañas de Hierro
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo 1: Las Montañas de Hierro"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Te adentras en las Montañas de Hierro, un lugar inhóspito y lleno de peligros.${NC}"
echo -e "${BLUE}Los enanos, conocidos por su desconfianza hacia los forasteros, son la primera clave para cumplir la profecía.${NC}"
echo -e "${BLUE}Te encuentras con Thorgrim, el líder enano, quien te pone a prueba.${NC}"
echo "¿Qué decides hacer?"
echo "1. Demostrar tu valía en combate."
echo "2. Negociar con Thorgrim."
read -p "Selecciona una opción (1-2): " decision

case $decision in
    1)
        echo -e "${GREEN}Decides demostrar tu valía en combate.${NC}"
        combat "Guerrero Enano" 120 20 25
        echo -e "${BLUE}Thorgrim, impresionado por tu coraje, decide unirse a tu causa.${NC}"
        enanos_aliados=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    2)
        echo -e "${GREEN}Decides negociar con Thorgrim.${NC}"
        echo -e "${BLUE}Tras una larga conversación, logras convencerlo de unirse a tu causa.${NC}"
        enanos_aliados=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

# Capítulo 2: El Bosque Eterno
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo 2: El Bosque Eterno"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Te adentras en el Bosque Eterno, un lugar mágico y misterioso donde los elfos habitan en armonía con la naturaleza.${NC}"
echo -e "${BLUE}Te encuentras con Aelindra, la líder de los elfos, quien te pone a prueba.${NC}"
echo "¿Qué decides hacer?"
echo "1. Demostrar tu valía en una prueba de habilidad."
echo "2. Convencer a Aelindra con palabras."
read -p "Selecciona una opción (1-2): " decision

case $decision in
    1)
        echo -e "${GREEN}Decides demostrar tu valía en una prueba de habilidad.${NC}"
        combat "Guardián Élfico" 100 30 10
        echo -e "${BLUE}Aelindra, impresionada por tu destreza, decide unirse a tu causa.${NC}"
        elfos_aliados=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    2)
        echo -e "${GREEN}Decides convencer a Aelindra con palabras.${NC}"
        echo -e "${BLUE}Tras una larga conversación, logras convencerla de unirse a tu causa.${NC}"
        elfos_aliados=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

# Capítulo 3: Las Llanuras del Amanecer
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo 3: Las Llanuras del Amanecer"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Llegas a las Llanuras del Amanecer, el hogar de los humanos.${NC}"
echo -e "${BLUE}Te encuentras con Lord Cedric, el líder humano, quien te pone a prueba.${NC}"
echo "¿Qué decides hacer?"
echo "1. Demostrar tu valía en combate."
echo "2. Negociar con Lord Cedric."
read -p "Selecciona una opción (1-2): " decision

case $decision in
    1)
        echo -e "${GREEN}Decides demostrar tu valía en combate.${NC}"
        combat "Guerrero Humano" 110 25 20
        echo -e "${BLUE}Lord Cedric, impresionado por tu coraje, decide unirse a tu causa.${NC}"
        humanos_aliados=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    2)
        echo -e "${GREEN}Decides negociar con Lord Cedric.${NC}"
        echo -e "${BLUE}Tras una larga conversación, logras convencerlo de unirse a tu causa.${NC}"
        humanos_aliados=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

# Capítulo 4: La Ciudad Abandonada
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo 4: La Ciudad Abandonada"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Te adentras en una Ciudad Abandonada, un lugar lleno de secretos y peligros.${NC}"
echo -e "${BLUE}Exploras las ruinas en busca de pistas sobre la profecía de Bash.${NC}"
echo "¿Qué decides hacer?"
echo "1. Investigar el ayuntamiento."
echo "2. Explorar las casas abandonadas."
read -p "Selecciona una opción (1-2): " decision

case $decision in
    1)
        echo -e "${GREEN}Decides investigar el ayuntamiento.${NC}"
        echo -e "${BLUE}Encuentras un Pergamino Antiguo que revela parte de la profecía.${NC}"
        ciudad_explorada=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    2)
        echo -e "${RED}Decides explorar las casas abandonadas.${NC}"
        echo -e "${BLUE}Te encuentras con una trampa y pierdes parte de tu salud.${NC}"
        player_hp=$((player_hp - 50))
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

# Encuentro con el Vagabundo
clear
echo -e "${YELLOW}=============================================="
echo " Encuentro con el Vagabundo"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Mientras exploras la ciudad, te encuentras con un vagabundo misterioso.${NC}"
echo -e "${BLUE}El vagabundo parece débil y hambriento.${NC}"
echo "¿Qué decides hacer?"
echo "1. Ayudar al vagabundo."
echo "2. Ignorarlo y seguir tu camino."
read -p "Selecciona una opción (1-2): " decision

case $decision in
    1)
        echo -e "${GREEN}Decides ayudar al vagabundo. Le das comida y agua.${NC}"
        echo -e "${BLUE}El vagabundo, agradecido, te entrega una espada legendaria.${NC}"
        player_sword="Espada Legendaria"
        player_atk=$((player_atk + 100))
        vagabundo_ayudado=true
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    2)
        echo -e "${RED}Ignoras al vagabundo. De repente, se transforma en un demonio y te ataca.${NC}"
        combat "Demonio" 150 35 25
        echo -e "${RED}Logras derrotar al demonio, y su sangre de repente toma forma de una espada demoniaca en llamas rojas${NC}"
        echo -e "${RED}con un aura oscura muy poderosa que te atrae a tomarla.${NC}"
        player_sword="Espada Demoniaca"
        player_atk=$((player_atk + 300))
        player_def=$((player_def + 300))
        vagabundo_ayudado=false
        player_def=10
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read
        ;;
    *)
        echo "Opción inválida. Saliendo..."
        exit 1
        ;;
esac

# Combate contra el jefe de la Ciudad Abandonada
combat "Guardián de las Ruinas" 200 30 35

# Capítulo 5: La Cueva de los Secretos
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo 5: La Cueva de los Secretos"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Te adentras en la Cueva de los Secretos, un laberinto oscuro y traicionero.${NC}"
echo -e "${BLUE}Encuentras el Artefacto de Bash, una reliquia perdida que aumenta tu poder.${NC}"
player_artifact="Artefacto de Bash"
player_atk=$((player_atk + 50))
cueva_explorada=true

# Combate contra el jefe de la Cueva de los Secretos
combat "Guardián de la Cueva" 180 40 15

# Capítulo 6: El Pantano de las Sombras
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo 6: El Pantano de las Sombras"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Te adentras en el Pantano de las Sombras, un lugar oscuro y lúgubre.${NC}"
echo -e "${BLUE}Encuentras a un espíritu que te guía hacia el Dragón de las Sombras.${NC}"
echo -e "${BLUE}Presiona Enter para continuar...${NC}"
read

# Capítulo Final: El Dragón de las Sombras
clear
echo -e "${YELLOW}=============================================="
echo " Capítulo Final: El Dragón de las Sombras"
echo "=============================================="
echo -e "${NC}"
echo -e "${BLUE}Con todos los aliados reunidos y las reliquias en tu poder, te enfrentas al Dragón de las Sombras.${NC}"
echo -e "${BLUE}El dragón, una criatura colosal de escamas negras y ojos llameantes, es la encarnación del mal.${NC}"
echo -e "${BLUE}Los enanos, elfos y humanos luchan a tu lado en una batalla épica.${NC}"
combat "Dragón de las Sombras" 300 45 30

# Epílogo: El Héroe de Eredrim
clear
echo -e "${YELLOW}=============================================="
echo " Epílogo: El Héroe de Eredrim"
echo "=============================================="
echo -e "${NC}"
echo -e "${GREEN}Con el dragón derrotado, la paz regresa a los reinos de Eredrim.${NC}"
echo -e "${BLUE}Eres aclamado como el héroe que cumplió la profecía de Bash.${NC}"
echo -e "${BLUE}Los enanos, elfos y humanos celebran tu victoria, y tu nombre, $player_name, es recordado por generaciones.${NC}"
echo -e "${BLUE}Sin embargo, el Bash te susurra que nuevas amenazas acechan en el horizonte.${NC}"
echo -e "${BLUE}Tu destino está ligado al equilibrio del mundo, y te preparas para lo que vendrá.${NC}"
echo -e "${YELLOW}=============================================="
echo -e "${NC}"
