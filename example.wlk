class Persona {
  var property monedas = 20   // inicialmente 20 monedas
  var edad
  
  method recursos() = monedas
  
  // Una persona es destacada si tiene entre 18 y 65 años o más de 30 de recursos.
  method esDestacada() = edad.between(18, 65) or self.recursos() > 30

  method edadEntreCiertoRango(edadMinima, edadMaxima) = edad.between(edadMinima, edadMaxima)
  method tieneMasDeTantosRecursos(cantidad) = self.recursos() > cantidad

  method ganarMonedas(cantidad) {monedas += cantidad}
  method gastarMonedas(cantidad) {monedas -= cantidad}

  method cumplirAnios() {edad += 1}

  // Ser productor o constructor no es algo que se aprende con el tiempo o que se pueda cambiar. 
  // Para las personas que no son ni constructoras ni productoras, trabajar no les afecta ni altera el planeta.

  method trabajar(tiempo, planeta) {} // no afecta en nada  // metodo abstracto

}

class Construccion {
  method valor()  // metodo abstracto
}

class Muralla inherits Construccion {
  const longitud

  override method valor() = 10 * longitud 
}

class Museo inherits Construccion {
  const superficieCubierta
  const indiceImportancia //= 1.randomUpTo(5)

  override method valor() = superficieCubierta * indiceImportancia
}

class Planeta {
  const habitantes = []
  const construcciones = []

  method esHabitanteDelPlaneta(habitante) = habitantes.contains(habitante)

  method agregarConstruccion(nuevaConstruccion) {construcciones.add(nuevaConstruccion)}

  // que está formada por todos los habitantes destacados y el habitante que tenga más recursos.
  // con add, agrego el habitante con mas recursos al final
  // Si llegara a coincidir que el habitante con más recursos fuera tambien destacado, mantiene su pertenencia a la delegación.
  
  //method delegacionDiplomaticaV1() = self.habitantesDestacados().add(self.habitanteConMasRecurso()) NO!!

  // el filtro es segun si es el habitante es destacado o si el habitante es que tiene mas recursos!!
  method delegacionDiplomatica() = habitantes.filter({habitante => habitante.esDestacada() || self.esElHabitanteConMasRecursos(habitante)})

  //method habitantesDestacados() = habitantes.filter({habitante => habitante.esDestacada()})

  // NO existe otro habitante que tengas mas recursos que el habitante con mas recursos
  method esElHabitanteConMasRecursos(habitante) = not(habitantes.any({otroHabitante => otroHabitante.recursos() > habitante.recursos()})) 
  
  //method habitanteConMasRecursos() = habitantes.max({habitante => habitante.recursos()})

  method cantidadDelegacionDiplomatica() = self.delegacionDiplomatica().size()

  method esValioso() = self.totalValorConstrucciones() > 100

  method totalValorConstrucciones() = construcciones.sum({construccion => construccion.valor()})

  // Hacer que la delegación diplomática del planeta trabaje durante un determinado tiempo en su planeta

  //method trabajar(tiempo) {
  //  self.delegacionDiplomatica().forEach({persona => persona.trabajar(tiempo,self)})
  //}

  // Hacer que un planeta invada a otro y obligue a su delegación diplomática a trabajar para el planeta invasor.

  //method invadir(otroPlaneta, tiempo) {
  //  otroPlaneta.delegacionDiplomatica().forEach({persona => persona.trabajar(tiempo,self)})
  //}

  // PARA QUE NO HAYA REPETICION DE LOGICA!!

  method hacerQueLaDelegacionDiplomaticaTrabajeEnUnPlaneta(unPlaneta, tiempo) {
    self.delegacionDiplomatica().forEach({persona => persona.trabajar(tiempo,unPlaneta)})
  }

  method hacerQueDelegacionTrabajeEnSuPlaneta(tiempo) {
    self.hacerQueLaDelegacionDiplomaticaTrabajeEnUnPlaneta(self, tiempo)
  }

  method invadirUnPlanetaPorUnTiempo(otroPlaneta, tiempo) {
    otroPlaneta.hacerQueLaDelegacionDiplomaticaTrabajeEnUnPlaneta(self, tiempo)
  }

}

class Productor inherits Persona {
  const tecnicasConocidas = ["cultivo"]

  method cantidadTecnicasConocidas() = tecnicasConocidas.size()

  override method recursos() = super() * self.cantidadTecnicasConocidas()

  override method esDestacada() = super() or self.cantidadTecnicasConocidas() > 5

  // Acciones de un productor

  method realizarUnaTecnicaPor(tecnica, tiempo) {
    if(self.conoceLaTecnica(tecnica)) {
      self.ganarMonedas(3 * tiempo)
    }else   
      self.gastarMonedas(1)
  }

  method conoceLaTecnica(tecnica) = tecnicasConocidas.contains(tecnica)

  method aprenderUnaTecnica(tecnica) {tecnicasConocidas.add(tecnica)}

  method ultimaTecnicaAprendida() = tecnicasConocidas.last()

  override method trabajar(tiempo, planeta) {
    if(planeta.esHabitanteDelPlaneta(self))
      self.realizarUnaTecnicaPor(self.ultimaTecnicaAprendida(), tiempo)
    else 
      throw new DomainException(message = "El productor NO es habitante del planeta, por lo tanto NO puede trabajar en el")
  }
}

class Constructor inherits Persona {
  var cantConstruccionesRealizadas 
  const regionDondeVive
  const property inteligencia 

  override method recursos() = super() + (10 * cantConstruccionesRealizadas)

  override method esDestacada() = cantConstruccionesRealizadas > 5

  method aumentarConstrucciones() {cantConstruccionesRealizadas += 1}

  override method trabajar(tiempo, planeta) {
    planeta.agregarConstruccion(regionDondeVive.construccionAConstruirPorRegion(tiempo, self, self.recursos()))
    self.gastarMonedas(5)           // inversion
    self.aumentarConstrucciones()   // aumenta sus construcciones!!
  }
}

object montana {
  method construccionAConstruirPorRegion(tiempo, persona, recursos) = new Muralla(longitud = tiempo / 2) 
}

object costa {
  method construccionAConstruirPorRegion(tiempo, persona, recursos) = new Museo(superficieCubierta = tiempo, indiceImportancia = 1) 
}

object llanura {
  method construccionAConstruir(tiempo, persona, recursos) = 
    if(!persona.esDestacada()) {
      new Muralla(longitud = tiempo / 2)
    }else{ 
      const indice = (1..recursos).anyOne()
      if(indice > 5){
        throw new DomainException(message = "No se puede construir un museo con un indice mayor a 5")
      }else{
        new Museo(superficieCubierta = tiempo, indiceImportancia = indice)  // pero con un nivel entre 1 y 5, proporcional a sus recursos)
      }
    } 
}

// agregar una nueva región y que lo que construya dependa de la inteligencia del constructor

object regionInventada {
  method construccionAConstruirPorRegion(tiempo, persona, recursos) =
    if(persona.inteligencia() > 100)
      new Muralla(longitud = tiempo * recursos)
    else
      throw new DomainException(message = "El constructor no tiene la inteligente suficiente para construir la muralla")  
}