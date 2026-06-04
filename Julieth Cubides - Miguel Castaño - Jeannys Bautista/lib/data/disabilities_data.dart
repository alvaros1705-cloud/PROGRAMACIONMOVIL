import '../models/disability.dart';

const List<Disability> disabilities = [
  Disability(
    id: 'discapacidad_auditiva',
    name: 'Discapacidad Auditiva',
    shortDescription:
        'Pérdida parcial o total de la audición que afecta la comunicación y el aprendizaje; incluye hipoacusia y sordera.',
    fullDescription:
        'La discapacidad auditiva abarca desde la hipoacusia (pérdida auditiva parcial) hasta la sordera profunda. Puede ser prelocutiva (antes de adquirir el lenguaje) o poslocutiva. Los estudiantes sordos o con baja audición son personas con todas sus capacidades cognitivas intactas; la principal barrera es el acceso a la comunicación. Con intérpretes de lengua de señas, apoyos visuales y adaptaciones en la comunicación, pueden participar plenamente en el aula.',
    iconEmoji: '🦻',
    characteristics: [
      'Dificultad o imposibilidad para procesar la información auditiva.',
      'Puede usar lengua de señas o sistemas de comunicación aumentativa.',
      'Posibles dificultades en el desarrollo del lenguaje oral y escrito si la pérdida es prelocutiva.',
      'Mayor dependencia de apoyos visuales y escritos.',
      'Uso frecuente de audífonos, implantes u otros dispositivos de asistencia.',
      'Sensibilidad a entornos ruidosos o mal acondicionados acústicamente.',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Apoyo de intérprete de lengua de señas',
        description:
            'Si el estudiante usa lengua de señas, garantiza la presencia de un intérprete. Dirige siempre la comunicación al estudiante, no al intérprete, y asegúrate de que el intérprete tenga buena visibilidad.',
        iconEmoji: '🤟',
      ),
      PedagogicalStrategy(
        title: 'Hablar de frente y con claridad',
        description:
            'Colócate siempre de frente al estudiante cuando hablas para facilitar la lectura labial. Habla con claridad y a velocidad normal, sin exagerar los movimientos de la boca. No cubras tu rostro.',
        iconEmoji: '😊',
      ),
      PedagogicalStrategy(
        title: 'Apoyos visuales permanentes',
        description:
            'Escribe en el tablero las instrucciones, palabras clave y resúmenes de lo explicado verbalmente. Usa subtítulos en los videos y transcripciones de audio.',
        iconEmoji: '📺',
      ),
      PedagogicalStrategy(
        title: 'Ubicación óptima en el aula',
        description:
            'Ubica al estudiante en primera fila, o en una posición donde pueda ver al docente y a sus compañeros de frente. Evita que quede de espaldas al tablero o a las fuentes de luz.',
        iconEmoji: '🎯',
      ),
      PedagogicalStrategy(
        title: 'Reducir el ruido ambiental',
        description:
            'Minimiza el ruido de fondo en el aula (sillas, ventiladores, ruido exterior). Para estudiantes con hipoacusia que usan audífonos, el ruido de fondo es especialmente perturbador.',
        iconEmoji: '🔇',
      ),
      PedagogicalStrategy(
        title: 'Confirmar la comprensión',
        description:
            'Verifica regularmente que el estudiante ha comprendido mediante preguntas directas o pidiéndole que resuma. No asumas que por haber estado presente entendió todo el contenido.',
        iconEmoji: '✅',
      ),
    ],
  ),
  Disability(
    id: 'discapacidad_visual',
    name: 'Discapacidad Visual',
    shortDescription:
        'Condiciones que limitan la visión (baja visión o ceguera) y afectan el acceso a materiales visuales.',
    fullDescription:
        'La discapacidad visual engloba un amplio espectro de condiciones, desde la baja visión (visión reducida que no se corrige completamente con lentes) hasta la ceguera total. Afecta cómo el estudiante accede a la información y al entorno de aprendizaje. Con los apoyos adecuados (Braille, tecnología de asistencia, materiales adaptados), los estudiantes con discapacidad visual pueden participar plenamente en el aula y alcanzar sus metas académicas.',
    iconEmoji: '🦯',
    characteristics: [
      'Dificultad o imposibilidad de acceder a materiales impresos o visuales.',
      'Necesidad de apoyos táctiles, auditivos o digitales accesibles.',
      'Posible impacto en el desarrollo de conceptos espaciales y motrices.',
      'Dependencia de descripciones verbales y tecnologías de asistencia.',
      'Puede requerir bastón, perro guía o herramientas de orientación.',
      'Fatiga visual en casos de baja visión por esfuerzo prolongado.',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Descripción verbal detallada',
        description:
            'Narra en voz alta todo lo que escribes en el tablero, los gráficos y las imágenes. Describe el entorno físico cuando sea relevante para la actividad.',
        iconEmoji: '🗣️',
      ),
      PedagogicalStrategy(
        title: 'Materiales en formatos accesibles',
        description:
            'Proporciona documentos en formato digital accesible, audio o Braille según las necesidades del estudiante. Garantiza que el software utilizado en clase sea compatible con lectores de pantalla.',
        iconEmoji: '📄',
      ),
      PedagogicalStrategy(
        title: 'Organización predecible del aula',
        description:
            'Mantén los muebles y materiales en lugares fijos. Avisa con anticipación cualquier cambio en la distribución del aula para que el estudiante pueda orientarse con seguridad.',
        iconEmoji: '🏫',
      ),
      PedagogicalStrategy(
        title: 'Tecnología de asistencia',
        description:
            'Facilita el acceso a lectores de pantalla, magnificadores, impresoras Braille y software de texto a voz. Estas herramientas son esenciales para la participación activa en el aula.',
        iconEmoji: '🔊',
      ),
      PedagogicalStrategy(
        title: 'Aprendizaje táctil',
        description:
            'Utiliza materiales en relieve, mapas táctiles y maquetas tridimensionales para enseñar conceptos geográficos, científicos o matemáticos. El aprendizaje táctil compensa la falta de información visual.',
        iconEmoji: '🤲',
      ),
      PedagogicalStrategy(
        title: 'Asignación de compañero de apoyo',
        description:
            'Designa un compañero de confianza que pueda describir actividades, ayudar con materiales y apoyar la orientación en nuevos espacios, fomentando siempre la mayor autonomía posible.',
        iconEmoji: '🧑‍🤝‍🧑',
      ),
    ],
  ),
  Disability(
    id: 'autismo',
    name: 'Trastorno del Espectro Autista (TEA)',
    shortDescription:
        'Condición del neurodesarrollo que afecta la comunicación social y el comportamiento.',
    fullDescription:
        'El Trastorno del Espectro Autista (TEA) es una condición neurológica y del desarrollo que afecta cómo las personas se comunican, interactúan socialmente, aprenden y se comportan. El TEA es un "espectro" porque existe una gran variedad en el tipo y la gravedad de los síntomas. Puede presentarse con o sin discapacidad intelectual, con o sin dificultades en el lenguaje, y a menudo se acompaña de otras condiciones como el TDAH o la ansiedad.',
    iconEmoji: '🧩',
    characteristics: [
      'Dificultades en la comunicación e interacción social.',
      'Comportamientos repetitivos o rutinas rígidas.',
      'Intereses muy específicos e intensos.',
      'Sensibilidad sensorial inusual (hiper o hipo sensibilidad).',
      'Dificultad para interpretar lenguaje no verbal (gestos, expresiones).',
      'Preferencia por la previsibilidad y la estructura.',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Estructurar el entorno',
        description:
            'Organiza el aula con una rutina clara y predecible. Usa apoyos visuales como horarios pictográficos para anticipar cada actividad y reducir la ansiedad ante los cambios.',
        iconEmoji: '📅',
      ),
      PedagogicalStrategy(
        title: 'Apoyos visuales',
        description:
            'Utiliza imágenes, pictogramas, colores y esquemas para complementar las instrucciones verbales. Muchos estudiantes con TEA procesan mejor la información visual que la auditiva.',
        iconEmoji: '🖼️',
      ),
      PedagogicalStrategy(
        title: 'Instrucciones claras y concretas',
        description:
            'Da instrucciones cortas, directas y de una en una. Evita el lenguaje ambiguo, irónico o las metáforas. Verifica la comprensión, pidiendo al estudiante que explique la tarea con sus propias palabras.',
        iconEmoji: '📋',
      ),
      PedagogicalStrategy(
        title: 'Aprovechar sus intereses',
        description:
            'Conecta los contenidos del currículo con los temas de interés del estudiante para aumentar su motivación y participación. Esto facilita la comprensión y el aprendizaje significativo.',
        iconEmoji: '⭐',
      ),
      PedagogicalStrategy(
        title: 'Gestionar la sensibilidad sensorial',
        description:
            'Permite el uso de auriculares, ofrece asientos alejados de fuentes de ruido intenso y adapta la iluminación si es necesario. Un ambiente sensorial cómodo favorece la concentración.',
        iconEmoji: '🎧',
      ),
      PedagogicalStrategy(
        title: 'Tiempo adicional y descansos',
        description:
            'Ofrece tiempo extra para procesar la información y completar tareas. Programa pausas breves y estructuradas para prevenir la sobrecarga sensorial y emocional.',
        iconEmoji: '⏸️',
      ),
    ],
  ),
  Disability(
    id: 'tdah',
    name: 'Trastorno por Déficit de Atención e Hiperactividad (TDAH)',
    shortDescription:
        'Condición que implica dificultades de atención, hiperactividad e impulsividad.',
    fullDescription:
        'El TDAH es uno de los trastornos del neurodesarrollo más comunes en niños y adolescentes. Se caracteriza por un patrón persistente de inatención y/o hiperactividad-impulsividad que interfiere con el funcionamiento y el desarrollo. Existen tres presentaciones: predominantemente inatenta, predominantemente hiperactiva-impulsiva, y combinada. Los estudiantes con TDAH tienen el mismo potencial intelectual que sus pares, pero requieren estrategias específicas para canalizar su energía y mantener el enfoque.',
    iconEmoji: '⚡',
    characteristics: [
      'Dificultad para mantener la atención en tareas prolongadas.',
      'Olvido frecuente de materiales e instrucciones.',
      'Dificultad para seguir instrucciones paso a paso.',
      'Inquietud motora o dificultad para permanecer sentado.',
      'Impulsividad: actuar antes de pensar, interrumpir conversaciones.',
      'Hiperfoco en actividades de su interés.',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Fragmentar las tareas',
        description:
            'Divide las actividades largas en pasos pequeños y alcanzables. Presenta una sección a la vez y celebra cada logro parcial para mantener la motivación.',
        iconEmoji: '🧩',
      ),
      PedagogicalStrategy(
        title: 'Ubicación estratégica en el aula',
        description:
            'Sienta al estudiante cerca del docente, lejos de la puerta y de ventanas que puedan distraerlo. Una posición frontal facilita el contacto visual y el redireccionamiento.',
        iconEmoji: '🪑',
      ),
      PedagogicalStrategy(
        title: 'Instrucciones multimodales',
        description:
            'Combina instrucciones verbales con escritas en el tablero. Pide al estudiante que repita la instrucción antes de comenzar, para asegurar su comprensión.',
        iconEmoji: '📝',
      ),
      PedagogicalStrategy(
        title: 'Movimiento y descansos activos',
        description:
            'Incorpora pausas de movimiento breves (1-3 minutos) entre actividades. Asigna roles que impliquen moverse (repartir materiales, borrar el tablero), para canalizar la energía.',
        iconEmoji: '🏃',
      ),
      PedagogicalStrategy(
        title: 'Refuerzo positivo inmediato',
        description:
            'Elogia de forma específica e inmediata las conductas positivas. Los sistemas de puntos o contratos de comportamiento pueden ser muy efectivos para esta población.',
        iconEmoji: '🏆',
      ),
      PedagogicalStrategy(
        title: 'Apoyos organizacionales',
        description:
            'Usa agendas, listas de verificación y recordatorios visuales. Enséñale a usar colores para organizar sus materiales por asignatura, y reduce el desorden en su escritorio.',
        iconEmoji: '🗂️',
      ),
    ],
  ),
  Disability(
    id: 'sindrome_down',
    name: 'Síndrome de Down',
    shortDescription:
        'Condición genética que puede implicar discapacidad intelectual leve a moderada.',
    fullDescription:
        'El Síndrome de Down es una condición cromosómica causada por la presencia total o parcial de un cromosoma 21 adicional. Se asocia con rasgos físicos característicos, discapacidad intelectual de grado variable (generalmente leve a moderada) y retrasos en el desarrollo. Sin embargo, con el apoyo adecuado, los estudiantes con Síndrome de Down pueden aprender, socializar y lograr importantes avances académicos y personales. Su ritmo de aprendizaje suele ser más lento pero no menos valioso.',
    iconEmoji: '💛',
    characteristics: [
      'Discapacidad intelectual de leve a moderada.',
      'Ritmo de aprendizaje más lento que el promedio.',
      'Buenas habilidades sociales y comunicativas (generalmente).',
      'Dificultades en la memoria a corto plazo.',
      'Fortaleza en el aprendizaje visual.',
      'Posibles dificultades de lenguaje y motricidad fina.',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Aprendizaje visual y concreto',
        description:
            'Usa objetos reales, imágenes, videos y manipulativos para enseñar conceptos abstractos. El aprendizaje experiencial y concreto es especialmente eficaz para estos estudiantes.',
        iconEmoji: '👁️',
      ),
      PedagogicalStrategy(
        title: 'Repetición y práctica constante',
        description:
            'Repite los contenidos con variedad de actividades y formatos. La práctica distribuida en el tiempo consolida el aprendizaje y compensa las dificultades de memoria a corto plazo.',
        iconEmoji: '🔄',
      ),
      PedagogicalStrategy(
        title: 'Adaptar los materiales',
        description:
            'Simplifica los textos, reduce la cantidad de información por página y usa letras de mayor tamaño. Adapta las evaluaciones al nivel real del estudiante, sin excluirlo del currículo general.',
        iconEmoji: '📚',
      ),
      PedagogicalStrategy(
        title: 'Inclusión y trabajo cooperativo',
        description:
            'Diseña actividades grupales donde el estudiante pueda participar activamente según sus fortalezas. El trabajo entre pares fomenta la socialización y el aprendizaje mutuo.',
        iconEmoji: '🤝',
      ),
      PedagogicalStrategy(
        title: 'Rutinas predecibles',
        description:
            'Establece rutinas claras en el aula para que el estudiante sepa qué esperar. La anticipación reduce la ansiedad y facilita la transición entre actividades.',
        iconEmoji: '🕐',
      ),
      PedagogicalStrategy(
        title: 'Fomentar la autonomía',
        description:
            'Enseña habilidades de autocuidado y autonomía gradualmente. Celebra los logros pequeños para construir autoestima y motivación hacia el aprendizaje.',
        iconEmoji: '🌱',
      ),
    ],
  ),
  Disability(
    id: 'sindrome_asperger',
    name: 'Síndrome de Asperger',
    shortDescription:
        'Condición del neurodesarrollo dentro del espectro autista caracterizada por dificultades sociales y patrones restrictivos de interés.',
    fullDescription:
        'El Síndrome de Asperger se considera parte del Trastorno del Espectro Autista (TEA). Las personas con Asperger suelen tener lenguaje y cognición preservados, pero presentan dificultades para interpretar señales sociales, entender normas no explícitas y manejar cambios en la rutina. Pueden mostrar intereses intensos y patrones repetitivos de comportamiento.',
    iconEmoji: '🧠',
    characteristics: [
      'Dificultades en la interacción social y en la lectura de señales no verbales.',
      'Intereses intensos y enfoque profundo en temas concretos.',
      'Dificultad con cambios inesperados o transiciones.',
      'Lenguaje formal o pedante en algunos casos, con comprensión pragmática reducida.',
      'Sensibilidad sensorial a ruidos, luces o texturas.',
      'Buena memoria para detalles y algoritmos concretos.',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Apoyo en habilidades sociales',
        description:
            'Trabaja habilidades sociales explícitas con role-playing y ejemplos concretos. Enseña normas sociales paso a paso, no des por sentadas las expectativas implícitas.',
        iconEmoji: '🤝',
      ),
      PedagogicalStrategy(
        title: 'Estructura y rutinas claras',
        description:
            'Proporciona horarios visibles, avisos ante cambios y transiciones graduales para reducir la ansiedad y facilitar la adaptación.',
        iconEmoji: '📅',
      ),
      PedagogicalStrategy(
        title: 'Adaptar la comunicación',
        description:
            'Da instrucciones claras, concretas y en pasos. Evita expresiones ambiguas, ironías o metáforas que puedan malinterpretarse.',
        iconEmoji: '🗣️',
      ),
      PedagogicalStrategy(
        title: 'Aprovechar intereses',
        description:
            'Integra los intereses del estudiante en actividades de aprendizaje para aumentar la motivación y la participación.',
        iconEmoji: '⭐',
      ),
      PedagogicalStrategy(
        title: 'Espacios de regulación sensorial',
        description:
            'Ofrece lugares o materiales para autorregularse (auriculares, pausas, objetos de manipulación) cuando la sobrecarga sensorial aparezca.',
        iconEmoji: '🎧',
      ),
      PedagogicalStrategy(
        title: 'Feedback claro y específico',
        description:
            'Proporciona retroalimentación concreta y orientada a comportamientos observables; evita evaluaciones vagas.',
        iconEmoji: '✅',
      ),
    ],
  ),
  Disability(
    id: 'sindrome_tourette',
    name: 'Síndrome de Tourette',
    shortDescription:
        'Trastorno neurológico caracterizado por tics motores y vocales persistentes.',
    fullDescription:
        'El Síndrome de Tourette es un trastorno del neurodesarrollo que implica la presencia de múltiples tics motores y al menos un tic vocal durante más de un año. Los tics pueden variar en intensidad y frecuencia y a menudo se agravan con el estrés o la fatiga. Muchas personas con Tourette también presentan condiciones asociadas como TDAH u OCD.',
    iconEmoji: '🔁',
    characteristics: [
      'Tics motores (gestos, movimientos repetidos) y vocales (sonidos, palabras).',
      'Variación en la frecuencia e intensidad de los tics a lo largo del tiempo.',
      'Aumento de tics en situaciones de estrés, cansancio o excitación.',
      'Posible coexistencia con TDAH, ansiedad u otros trastornos.',
      'Conciencia parcial o total de los tics y sensación previa (premonición).',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Entorno comprensivo',
        description:
            'Educa al grupo sobre Tourette para reducir el estigma. Mantén una actitud calmada y evita llamar la atención innecesaria sobre los tics.',
        iconEmoji: '🤝',
      ),
      PedagogicalStrategy(
        title: 'Permitir pausas y espacios',
        description:
            'Ofrece momentos para moverse o regularse sin penalización cuando los tics aumenten.',
        iconEmoji: '⏸️',
      ),
      PedagogicalStrategy(
        title: 'Minimizar la presión social',
        description:
            'Evita exigir supresión de tics ante la clase; fomentar la aceptación y estrategias de afrontamiento en privado cuando sea necesario.',
        iconEmoji: '🛡️',
      ),
      PedagogicalStrategy(
        title: 'Coordinación con especialistas',
        description:
            'Trabaja con psicólogos o neurólogos cuando los tics interfieran notablemente en el aprendizaje o la seguridad.',
        iconEmoji: '🏥',
      ),
      PedagogicalStrategy(
        title: 'Adaptaciones en evaluaciones',
        description:
            'Permite alternativas para demostrar el aprendizaje si los tics interfieren con exámenes cronometrados o tareas orales.',
        iconEmoji: '📝',
      ),
    ],
  ),
  Disability(
    id: 'discapacidad_intelectual',
    name: 'Discapacidad Intelectual',
    shortDescription:
        'Limitaciones significativas en el funcionamiento intelectual y la conducta adaptativa.',
    fullDescription:
        'La discapacidad intelectual (DI) se caracteriza por limitaciones significativas tanto en el funcionamiento intelectual (razonamiento, aprendizaje, resolución de problemas) como en la conducta adaptativa (habilidades conceptuales, sociales y prácticas). Se origina antes de los 18 años. Los estudiantes con DI pueden aprender y desarrollarse, pero necesitan apoyos intensivos, currículos adaptados y una enseñanza cuidadosamente estructurada que parte de sus fortalezas e intereses.',
    iconEmoji: '🌟',
    characteristics: [
      'Dificultades generalizadas en el aprendizaje.',
      'Procesamiento de información más lento.',
      'Dificultad para generalizar conocimientos a nuevos contextos.',
      'Limitaciones en habilidades de autogestión y planificación.',
      'Necesidad de mayor repetición para consolidar aprendizajes.',
      'Variabilidad amplia: existen diferentes grados (leve, moderado, severo).',
    ],
    strategies: [
      PedagogicalStrategy(
        title: 'Diseño Universal para el Aprendizaje (DUA)',
        description:
            'Aplica principios DUA: ofrece múltiples medios de representación, acción/expresión y motivación. Esto beneficia a todos los estudiantes, y es especialmente crucial para quienes tienen DI.',
        iconEmoji: '🌐',
      ),
      PedagogicalStrategy(
        title: 'Currículo funcional y significativo',
        description:
            'Vincula los contenidos académicos con situaciones de la vida real. Enseñar a partir de contextos cotidianos hace el aprendizaje más significativo y transferible.',
        iconEmoji: '🏠',
      ),
      PedagogicalStrategy(
        title: 'Encadenamiento de tareas',
        description:
            'Descompón las habilidades complejas en pasos muy pequeños y enséñalos secuencialmente. Refuerza cada paso dominado antes de introducir el siguiente.',
        iconEmoji: '🔗',
      ),
      PedagogicalStrategy(
        title: 'Refuerzo constante y positivo',
        description:
            'Usa el refuerzo inmediato y específico para fortalecer conductas y aprendizajes deseados. El elogio genuino y las recompensas simbólicas incrementan la motivación.',
        iconEmoji: '👏',
      ),
      PedagogicalStrategy(
        title: 'Colaboración con familia y especialistas',
        description:
            'Mantén comunicación estrecha con la familia y el equipo interdisciplinario (psicólogos, terapeutas). La coherencia entre los entornos escolar y familiar maximiza el progreso.',
        iconEmoji: '👨‍👩‍👧',
      ),
      PedagogicalStrategy(
        title: 'Evaluación auténtica',
        description:
            'Evalúa el progreso con portafolios, observación directa y tareas en contexto real, no solo con pruebas escritas estándar. Reconoce los avances individuales, no la comparación con el grupo.',
        iconEmoji: '📊',
      ),
    ],
  ),
];
