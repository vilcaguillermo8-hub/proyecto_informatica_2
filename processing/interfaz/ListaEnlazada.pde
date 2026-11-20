/**
 * ListaEnlazada.pde
 * Aca armo la bitacora con una lista enlazada
 * Cada evento queda en un nodo y cada nodo apunta al siguiente
 * La uso para practicar memoria dinamica: los nodos se crean con new
 */

/**
 * NodoEvento
 * Es una celda de la lista
 * Existe porque el historial necesita guardar un evento y ademas saber cual viene despues
 * El campo siguiente es una referencia al proximo nodo, no una copia del nodo
 */
class NodoEvento {
  RegistroEvento dato = null;
  NodoEvento siguiente = null;

  NodoEvento(RegistroEvento evento) {
    dato = evento;
  }
}

/**
 * ListaEnlazadaEventos
 * Administra la secuencia de eventos
 * Existe porque quiero un historial que crezca y se recorte sin mover todo un arreglo
 * Cuando paso la capacidad, saco el nodo mas viejo para no acumular memoria
 * La cabeza siempre apunta al primer evento guardado
 */
class ListaEnlazadaEventos {
  NodoEvento cabeza = null;
  int cantidad = 0;
  int capacidadMaxima = 0;

  ListaEnlazadaEventos(int capacidad) {
    // Si me dan un valor raro, uso 1 para no quedar con una lista que no guarda nada
    if (capacidad <= 0) {
      println("ERROR: capacidad invalida, se usa 1");
      capacidad = 1;
    }
    capacidadMaxima = capacidad;
  }

  boolean agregar(RegistroEvento evento) {
    if (evento == null) {
      println("ERROR: evento nulo");
      return false;
    }

    // Creo el nodo nuevo con new, por eso cada evento ocupa su propia memoria
    NodoEvento nodoNuevo = new NodoEvento(evento);

    // Si la lista esta vacia, el nuevo nodo pasa a ser la cabeza
    // Si no, recorro hasta el final y engancho el nodo ahi
    if (cabeza == null) {
      cabeza = nodoNuevo;
    } else {
      NodoEvento actual = cabeza;
      while (actual.siguiente != null) {
        actual = actual.siguiente;
      }
      actual.siguiente = nodoNuevo;
    }

    cantidad++;

    // Como siempre agrego al final, el primero es el mas antiguo
    while (cantidad > capacidadMaxima) {
      eliminarPrimero();
    }

    return true;
  }

  void eliminarPrimero() {
    if (cabeza == null) {
      return;
    }
    // La cabeza pasa a ser el siguiente nodo
    NodoEvento viejo = cabeza;
    cabeza = cabeza.siguiente;

    // Pongo los campos en null para no dejar referencias colgando
    viejo.dato = null;
    viejo.siguiente = null;
    cantidad--;
  }

  RegistroEvento obtener(int indice) {
    if (indice < 0 || indice >= cantidad) {
      return null;
    }
    // No tengo indice directo, asi que camino nodo por nodo
    NodoEvento actual = cabeza;
    int contador = 0;
    while (actual != null) {
      if (contador == indice) {
        return actual.dato;
      }
      actual = actual.siguiente;
      contador++;
    }
    return null;
  }

  int tamaño() {
    // Lo uso para recorrer la lista desde fuera y para saber si hay eventos
    return cantidad;
  }

  RegistroEvento obtenerUltimo() {
    if (cabeza == null) {
      return null;
    }
    // El ultimo nodo es el evento mas reciente
    NodoEvento actual = cabeza;
    while (actual.siguiente != null) {
      actual = actual.siguiente;
    }
    return actual.dato;
  }

  void limpiar() {
    NodoEvento actual = cabeza;
    while (actual != null) {
      // Guardo el siguiente antes de borrar la referencia actual
      NodoEvento siguienteNodo = actual.siguiente;
      actual.dato = null;
      actual.siguiente = null;
      actual = siguienteNodo;
    }
    cabeza = null;
    cantidad = 0;
  }

  String[] aArregloDeLineas() {
    // saveStrings necesita un arreglo de String, por eso paso la lista a texto
    String[] lineas = new String[cantidad];
    NodoEvento actual = cabeza;
    int indice = 0;
    while (actual != null && indice < lineas.length) {
      if (actual.dato != null) {
        lineas[indice] = actual.dato.formatearLinea();
      } else {
        lineas[indice] = "[--:--:--] evento sin dato";
      }
      actual = actual.siguiente;
      indice++;
    }
    return lineas;
  }
}
