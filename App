import { useState, useMemo } from "react";

const pad = (n) => String(n).padStart(2, "0");
const toKey = (d) => `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
const DIAS  = ["Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"];
const MESES = ["enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"];
const mins  = (hhmm) => { const [h,m]=(hhmm||"00:00").split(":").map(Number); return h*60+m; };
const cruzan = (a1,a2,b1,b2) => mins(a1)<mins(b2)&&mins(b1)<mins(a2);

// ── Colores de marca ─────────────────────────────────────
const BRAND      = "#1B6CA8";
const BRAND_DARK = "#0D3C60";
const BRAND_MID  = "#1565A0";
const GREEN      = "#1E8449";

// ── Categorías ───────────────────────────────────────────
const CATS = {
  trabajo:      { nombre:"Trabajo",       color:"#1B6CA8", bg:"#EBF3FA" },
  reunion:      { nombre:"Reunión",       color:"#C0392B", bg:"#FDECEA" },
  comida:       { nombre:"Comida",        color:"#D68910", bg:"#FEF9E7" },
  ejercicio:    { nombre:"Ejercicio",     color:"#1E8449", bg:"#EAFAF1" },
  personal:     { nombre:"Personal",      color:"#717D7E", bg:"#F2F3F4" },
  casa:         { nombre:"Casa",          color:"#117A65", bg:"#E8F8F5" },
  personalizado:{ nombre:"Personalizado", color:"#7D3C98", bg:"#F5EEF8" },
};

const COLORES = [BRAND, GREEN, "#C0392B", "#7D3C98", "#D68910", "#117A65"];
const EMOJIS  = ["🙂","🚀","🌟","💪","🦊","🌿","⚡","🎯","👷","🔧"];

// ── Rutinas base ─────────────────────────────────────────
const rutinaEkoSemana = () => [
  { inicio:"06:30", fin:"07:00", titulo:"Preparación y traslado",       cat:"personal"  },
  { inicio:"07:00", fin:"09:00", titulo:"Limpieza matutina · Bloque 1", cat:"trabajo"   },
  { inicio:"09:00", fin:"09:15", titulo:"Descanso",                     cat:"personal"  },
  { inicio:"09:15", fin:"12:00", titulo:"Limpieza matutina · Bloque 2", cat:"trabajo"   },
  { inicio:"12:00", fin:"13:00", titulo:"Almuerzo",                     cat:"comida"    },
  { inicio:"13:00", fin:"16:00", titulo:"Limpieza vespertina",          cat:"trabajo"   },
  { inicio:"16:00", fin:"16:15", titulo:"Cierre y entrega de turno",    cat:"reunion"   },
];
const rutinaEkoFinde = () => [
  { inicio:"07:00", fin:"07:15", titulo:"Preparación y traslado",       cat:"personal"  },
  { inicio:"07:15", fin:"11:00", titulo:"Limpieza especial · Bloque 1", cat:"trabajo"   },
  { inicio:"11:00", fin:"12:00", titulo:"Almuerzo",                     cat:"comida"    },
  { inicio:"12:00", fin:"15:00", titulo:"Limpieza especial · Bloque 2", cat:"trabajo"   },
  { inicio:"15:00", fin:"15:15", titulo:"Cierre y entrega de turno",    cat:"reunion"   },
];
const rutinaPersonalSemana = () => [
  { inicio:"07:00", fin:"07:30", titulo:"Rutina matutina personal",     cat:"personal"  },
  { inicio:"07:30", fin:"08:15", titulo:"Ejercicio",                    cat:"ejercicio" },
  { inicio:"08:15", fin:"09:15", titulo:"Desayuno",                     cat:"comida"    },
  { inicio:"09:15", fin:"12:00", titulo:"Trabajo · Bloque 1",           cat:"trabajo"   },
  { inicio:"12:00", fin:"13:30", titulo:"Almuerzo",                     cat:"comida"    },
  { inicio:"13:30", fin:"17:00", titulo:"Trabajo · Bloque 2",           cat:"trabajo"   },
  { inicio:"17:00", fin:"17:45", titulo:"Ejercicio / Deporte",          cat:"ejercicio" },
  { inicio:"19:00", fin:"20:00", titulo:"Cena",                         cat:"comida"    },
];
const rutinaPersonalFinde = () => [
  { inicio:"08:00", fin:"09:00", titulo:"Rutina matutina",              cat:"personal"  },
  { inicio:"09:00", fin:"10:00", titulo:"Ejercicio",                    cat:"ejercicio" },
  { inicio:"10:00", fin:"11:00", titulo:"Desayuno",                     cat:"comida"    },
  { inicio:"13:00", fin:"14:30", titulo:"Almuerzo",                     cat:"comida"    },
  { inicio:"19:00", fin:"20:00", titulo:"Cena",                         cat:"comida"    },
];

const TIPOS = {
  eko_operativo: { label:"Operativo Ecokhemia", semana:rutinaEkoSemana,      finde:rutinaEkoFinde      },
  personal:      { label:"Rutina personal",      semana:rutinaPersonalSemana, finde:rutinaPersonalFinde },
};

const genDia = (fecha, pl) => {
  const dow = fecha.getDay();
  const base = (dow===0||dow===6) ? pl.finde : pl.semana;
  return base().map((b,i) => ({ ...b, id:`${toKey(fecha)}-${i}`, hecho:false }))
               .sort((a,b) => mins(a.inicio)-mins(b.inicio));
};

// ── Perfiles iniciales de demo ───────────────────────────
const PERFILES_DEMO = [
  { id:"eko1",  nombre:"Ecokhemia",  emoji:"🧹", color:BRAND,  tipoRutina:"eko_operativo" },
  { id:"andy1", nombre:"Andy",       emoji:"🙂", color:GREEN,  tipoRutina:"personal"      },
];

// ══════════════════════════════════════════════════════════
export default function EkoRutinas() {
  const hoy = new Date();

  const [pantalla,  setPantalla]  = useState("perfiles");
  const [perfiles,  setPerfiles]  = useState(PERFILES_DEMO);
  const [perfil,    setPerfil]    = useState(null);
  const [plantilla, setPlantilla] = useState(null);
  const [fecha,     setFecha]     = useState(hoy);
  const [diaData,   setDiaData]   = useState([]);
  const [tabRutina, setTabRutina] = useState("semana");
  const [modal,     setModal]     = useState(false);
  const [nuevoBloque, setNuevoBloque] = useState({ titulo:"", inicio:"08:00", fin:"09:00", cat:"trabajo" });
  const [modalError,  setModalError]  = useState("");
  const [paso,  setPaso]  = useState(0);
  const [draft, setDraft] = useState({ nombre:"", emoji:"🙂", color:COLORES[0], tipoRutina:"personal" });
  const [confirmarEliminar, setConfirmarEliminar] = useState(null);

  const progreso = useMemo(() => {
    if (!diaData.length) return 0;
    return Math.round((diaData.filter(b=>b.hecho).length / diaData.length) * 100);
  }, [diaData]);

  const abrirPerfil = (p) => {
    setPerfil(p);
    const tipo = TIPOS[p.tipoRutina] || TIPOS.personal;
    const pl = { semana: tipo.semana, finde: tipo.finde };
    setPlantilla(pl);
    setDiaData(genDia(fecha, pl));
    setPantalla("dia");
  };

  const cambiarDia = (delta) => {
    const nueva = new Date(fecha);
    nueva.setDate(nueva.getDate() + delta);
    setFecha(nueva);
    setDiaData(genDia(nueva, plantilla));
  };

  const toggleHecho = (id) =>
    setDiaData(prev => prev.map(b => b.id===id ? {...b, hecho:!b.hecho} : b));

  const agregarBloque = () => {
    if (!nuevoBloque.titulo.trim())               { setModalError("Escribe un nombre."); return; }
    if (mins(nuevoBloque.inicio)>=mins(nuevoBloque.fin)) { setModalError("La hora de inicio debe ser antes del fin."); return; }
    const conf = diaData.find(b => cruzan(nuevoBloque.inicio, nuevoBloque.fin, b.inicio, b.fin));
    if (conf) { setModalError(`Conflicto con "${conf.titulo}" (${conf.inicio}–${conf.fin}).`); return; }
    const nuevo = { ...nuevoBloque, id:`custom-${Date.now()}`, hecho:false };
    setDiaData(prev => [...prev, nuevo].sort((a,b) => mins(a.inicio)-mins(b.inicio)));
    setModal(false);
    setNuevoBloque({ titulo:"", inicio:"08:00", fin:"09:00", cat:"trabajo" });
    setModalError("");
  };

  const crearPerfil = () => {
    if (!draft.nombre.trim()) return;
    const nuevo = { id:`p${Date.now()}`, nombre:draft.nombre.trim(), emoji:draft.emoji, color:draft.color, tipoRutina:draft.tipoRutina };
    setPerfiles(prev => [...prev, nuevo]);
    setPaso(0);
    setDraft({ nombre:"", emoji:"🙂", color:COLORES[0], tipoRutina:"personal" });
    abrirPerfil(nuevo);
  };

  const eliminarPerfil = (pid) => {
    setPerfiles(prev => prev.filter(p => p.id !== pid));
    setConfirmarEliminar(null);
  };

  // ── Gradiente header helper ─────────────────────────────
  const headerStyle = {
    background:`linear-gradient(160deg, ${BRAND_DARK} 0%, ${BRAND} 100%)`,
    padding:"0 0 20px",
    borderRadius:"0 0 24px 24px",
  };

  // ════════════════════════════════════════════════════════
  // PANTALLA: PERFILES
  // ════════════════════════════════════════════════════════
  if (pantalla==="perfiles") return (
    <div style={{minHeight:"100vh", background:"#F0F4F8", fontFamily:"Arial, sans-serif"}}>
      <div style={headerStyle}>
        <div style={{padding:"32px 20px 4px", display:"flex", alignItems:"center", gap:12}}>
          <span style={{fontSize:30}}>🧹</span>
          <div>
            <div style={{color:"white", fontSize:22, fontWeight:700, letterSpacing:0.5}}>EkoRutinas</div>
            <div style={{color:"rgba(255,255,255,0.7)", fontSize:13}}>Ecokhemia Cleaning Science</div>
          </div>
        </div>
        <div style={{padding:"10px 20px 0", color:"rgba(255,255,255,0.75)", fontSize:13}}>
          Selecciona tu perfil para continuar
        </div>
      </div>

      <div style={{padding:"20px 16px", maxWidth:480, margin:"0 auto"}}>
        {perfiles.length===0 && (
          <div style={{background:"white", borderRadius:16, padding:32, textAlign:"center", marginBottom:16, boxShadow:"0 2px 8px rgba(0,0,0,0.08)"}}>
            <span style={{fontSize:48}}>👷</span>
            <p style={{color:"#777", fontSize:14, margin:"12px 0 0"}}>No hay perfiles todavía.<br/>Crea el primero aquí abajo.</p>
          </div>
        )}

        {perfiles.map(p => (
          <div key={p.id} style={{background:"white", borderRadius:16, padding:"14px 16px", marginBottom:12, display:"flex", alignItems:"center", gap:14, boxShadow:"0 2px 8px rgba(0,0,0,0.06)", border:"2px solid transparent", transition:"border 0.15s", cursor:"pointer"}}
            onClick={() => abrirPerfil(p)}
            onMouseOver={e=>e.currentTarget.style.border=`2px solid ${p.color}`}
            onMouseOut={e=>e.currentTarget.style.border="2px solid transparent"}>
            <div style={{width:50, height:50, borderRadius:25, background:p.color, display:"flex", alignItems:"center", justifyContent:"center", fontSize:26, flexShrink:0}}>
              {p.emoji}
            </div>
            <div style={{flex:1, minWidth:0}}>
              <div style={{fontWeight:700, fontSize:17, color:"#222"}}>{p.nombre}</div>
              <div style={{fontSize:12, color:"#888", marginTop:2}}>{TIPOS[p.tipoRutina]?.label || "Rutina personalizada"}</div>
            </div>
            <button onClick={e=>{ e.stopPropagation(); setConfirmarEliminar(p.id); }}
              style={{background:"#FDE8E8", border:"none", color:"#C00", borderRadius:8, padding:"7px 11px", cursor:"pointer", fontSize:15, flexShrink:0}}>🗑</button>
            <div style={{color:"#CCC", fontSize:22, flexShrink:0}}>›</div>
          </div>
        ))}

        <button onClick={()=>{ setPaso(0); setPantalla("asistente"); }}
          style={{width:"100%", padding:"16px", background:`linear-gradient(135deg,${BRAND},${GREEN})`, color:"white", border:"none", borderRadius:16, fontSize:16, fontWeight:700, cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:8, marginTop:4, boxShadow:`0 4px 16px ${BRAND}44`}}>
          <span style={{fontSize:22}}>+</span> Nuevo perfil
        </button>
      </div>

      {/* Modal confirmar eliminar */}
      {confirmarEliminar && (
        <div style={{position:"fixed", inset:0, background:"rgba(0,0,0,0.5)", display:"flex", alignItems:"center", justifyContent:"center", zIndex:200, padding:20}}>
          <div style={{background:"white", borderRadius:20, padding:28, maxWidth:320, width:"100%", textAlign:"center"}}>
            <span style={{fontSize:44}}>🗑</span>
            <div style={{fontWeight:700, fontSize:17, color:"#222", margin:"12px 0 8px"}}>¿Eliminar perfil?</div>
            <div style={{color:"#666", fontSize:14, marginBottom:24}}>Esta acción no se puede deshacer.</div>
            <div style={{display:"flex", gap:10}}>
              <button onClick={()=>setConfirmarEliminar(null)} style={{flex:1, padding:"12px", borderRadius:12, border:"1.5px solid #ddd", background:"white", fontWeight:600, cursor:"pointer", fontSize:15}}>Cancelar</button>
              <button onClick={()=>eliminarPerfil(confirmarEliminar)} style={{flex:1, padding:"12px", borderRadius:12, border:"none", background:"#C00", color:"white", fontWeight:700, cursor:"pointer", fontSize:15}}>Eliminar</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );

  // ════════════════════════════════════════════════════════
  // PANTALLA: ASISTENTE
  // ════════════════════════════════════════════════════════
  if (pantalla==="asistente") {
    const pasos = [
      <div key={0}>
        <p style={{color:"#555", fontSize:15, marginBottom:16}}>¿Cómo te llamas o cuál es tu nombre en la empresa?</p>
        <input value={draft.nombre} onChange={e=>setDraft({...draft,nombre:e.target.value})}
          placeholder="Ej: María, Operario 1, Turno A..."
          style={{width:"100%", padding:"14px 16px", borderRadius:12, border:`2px solid ${BRAND}`, fontSize:16, outline:"none", boxSizing:"border-box"}}/>
      </div>,
      <div key={1}>
        <p style={{color:"#555", fontSize:15, marginBottom:16}}>Elige un avatar:</p>
        <div style={{display:"grid", gridTemplateColumns:"repeat(5,1fr)", gap:10}}>
          {EMOJIS.map(e=>(
            <button key={e} onClick={()=>setDraft({...draft,emoji:e})}
              style={{fontSize:26, padding:"10px", borderRadius:12, border:`3px solid ${draft.emoji===e?BRAND:"#E0E0E0"}`, background:draft.emoji===e?"#EBF3FA":"white", cursor:"pointer"}}>
              {e}
            </button>
          ))}
        </div>
      </div>,
      <div key={2}>
        <p style={{color:"#555", fontSize:15, marginBottom:16}}>Elige un color:</p>
        <div style={{display:"flex", gap:14, flexWrap:"wrap", justifyContent:"center"}}>
          {COLORES.map(c=>(
            <button key={c} onClick={()=>setDraft({...draft,color:c})}
              style={{width:52, height:52, borderRadius:26, background:c, border:`4px solid ${draft.color===c?"#222":"transparent"}`, cursor:"pointer"}}/>
          ))}
        </div>
      </div>,
      <div key={3}>
        <p style={{color:"#555", fontSize:15, marginBottom:16}}>¿Qué tipo de rutina necesitas?</p>
        {Object.entries(TIPOS).map(([k,v])=>(
          <div key={k} onClick={()=>setDraft({...draft,tipoRutina:k})}
            style={{padding:"14px 16px", borderRadius:12, border:`2px solid ${draft.tipoRutina===k?BRAND:"#E0E0E0"}`, marginBottom:10, cursor:"pointer", background:draft.tipoRutina===k?"#EBF3FA":"white", display:"flex", alignItems:"center", gap:12}}>
            <span style={{fontSize:24}}>{k==="eko_operativo"?"🧹":"🏠"}</span>
            <div>
              <div style={{fontWeight:700, color:"#222", fontSize:15}}>{v.label}</div>
              <div style={{fontSize:12, color:"#888"}}>{k==="eko_operativo"?"Turnos de limpieza Ecokhemia":"Rutina adaptable personal"}</div>
            </div>
          </div>
        ))}
      </div>
    ];

    return (
      <div style={{minHeight:"100vh", background:"#F0F4F8", fontFamily:"Arial, sans-serif"}}>
        <div style={headerStyle}>
          <div style={{padding:"20px 20px 12px"}}>
            <button onClick={()=>setPantalla("perfiles")} style={{background:"rgba(255,255,255,0.18)", border:"none", color:"white", borderRadius:8, padding:"7px 14px", cursor:"pointer", marginBottom:14, fontSize:13}}>← Volver</button>
            <div style={{color:"white", fontSize:20, fontWeight:700}}>Crear nuevo perfil</div>
            <div style={{color:"rgba(255,255,255,0.7)", fontSize:13, marginTop:2}}>Paso {paso+1} de {pasos.length}</div>
            <div style={{marginTop:10, height:5, background:"rgba(255,255,255,0.2)", borderRadius:3}}>
              <div style={{width:`${((paso+1)/pasos.length)*100}%`, height:"100%", background:"white", borderRadius:3, transition:"width 0.3s"}}/>
            </div>
          </div>
        </div>

        <div style={{padding:"20px 16px", maxWidth:480, margin:"0 auto"}}>
          <div style={{background:"white", borderRadius:16, padding:24, boxShadow:"0 2px 8px rgba(0,0,0,0.08)"}}>
            {pasos[paso]}
          </div>
          <div style={{display:"flex", gap:10, marginTop:16}}>
            {paso>0 && <button onClick={()=>setPaso(p=>p-1)} style={{flex:1, padding:"14px", borderRadius:12, border:`2px solid ${BRAND}`, background:"white", color:BRAND, fontWeight:700, fontSize:15, cursor:"pointer"}}>Atrás</button>}
            {paso<pasos.length-1
              ? <button onClick={()=>{ if(paso===0&&!draft.nombre.trim()) return; setPaso(p=>p+1); }}
                  style={{flex:1, padding:"14px", borderRadius:12, border:"none", background:BRAND, color:"white", fontWeight:700, fontSize:15, cursor:"pointer"}}>Siguiente</button>
              : <button onClick={crearPerfil}
                  style={{flex:1, padding:"14px", borderRadius:12, border:"none", background:GREEN, color:"white", fontWeight:700, fontSize:15, cursor:"pointer"}}>✓ Crear perfil</button>
            }
          </div>
        </div>
      </div>
    );
  }

  // ════════════════════════════════════════════════════════
  // PANTALLA: DÍA
  // ════════════════════════════════════════════════════════
  if (pantalla==="dia") {
    const esHoy = toKey(fecha)===toKey(hoy);
    return (
      <div style={{minHeight:"100vh", background:"#F0F4F8", fontFamily:"Arial, sans-serif", paddingBottom:80}}>
        <div style={headerStyle}>
          <div style={{padding:"20px 16px 0"}}>
            <div style={{display:"flex", justifyContent:"space-between", marginBottom:14}}>
              <button onClick={()=>{ setPantalla("perfiles"); setPerfil(null); }}
                style={{background:"rgba(255,255,255,0.18)", border:"none", color:"white", borderRadius:8, padding:"7px 12px", cursor:"pointer", fontSize:13}}>← Perfiles</button>
              <button onClick={()=>{ setTabRutina("semana"); setPantalla("rutina"); }}
                style={{background:"rgba(255,255,255,0.18)", border:"none", color:"white", borderRadius:8, padding:"7px 12px", cursor:"pointer", fontSize:13}}>⚙ Mi rutina</button>
            </div>
            <div style={{display:"flex", alignItems:"center", gap:12, marginBottom:14}}>
              <div style={{width:46, height:46, borderRadius:23, background:perfil.color, display:"flex", alignItems:"center", justifyContent:"center", fontSize:24}}>{perfil.emoji}</div>
              <div>
                <div style={{color:"white", fontWeight:700, fontSize:18}}>{perfil.nombre}</div>
                <div style={{color:"rgba(255,255,255,0.7)", fontSize:13}}>Ecokhemia Cleaning Science</div>
              </div>
            </div>

            {/* Nav fecha */}
            <div style={{display:"flex", alignItems:"center", justifyContent:"space-between", background:"rgba(255,255,255,0.15)", borderRadius:12, padding:"10px 14px", marginBottom:14}}>
              <button onClick={()=>cambiarDia(-1)} style={{background:"none", border:"none", color:"white", fontSize:24, cursor:"pointer", padding:"0 4px"}}>‹</button>
              <div style={{textAlign:"center"}}>
                <div style={{color:"white", fontWeight:700, fontSize:16}}>{DIAS[fecha.getDay()]} {fecha.getDate()} de {MESES[fecha.getMonth()]}</div>
                {esHoy && <div style={{color:"rgba(255,255,255,0.75)", fontSize:12}}>Hoy</div>}
              </div>
              <button onClick={()=>cambiarDia(1)} style={{background:"none", border:"none", color:"white", fontSize:24, cursor:"pointer", padding:"0 4px"}}>›</button>
            </div>

            {/* Progreso */}
            <div style={{marginBottom:4}}>
              <div style={{display:"flex", justifyContent:"space-between", marginBottom:5}}>
                <span style={{color:"rgba(255,255,255,0.75)", fontSize:12}}>Progreso del día</span>
                <span style={{color:"white", fontWeight:700, fontSize:13}}>{progreso}%</span>
              </div>
              <div style={{height:6, background:"rgba(255,255,255,0.25)", borderRadius:3}}>
                <div style={{width:`${progreso}%`, height:"100%", background:progreso===100?"#2ECC71":"white", borderRadius:3, transition:"width 0.4s"}}/>
              </div>
            </div>
          </div>
        </div>

        <div style={{padding:"14px 14px", maxWidth:520, margin:"0 auto"}}>
          {diaData.length===0 && (
            <div style={{background:"white", borderRadius:16, padding:32, textAlign:"center", boxShadow:"0 2px 8px rgba(0,0,0,0.06)"}}>
              <span style={{fontSize:48}}>📋</span>
              <p style={{color:"#888", marginTop:12}}>Sin actividades este día.<br/>Agrega una con el botón +.</p>
            </div>
          )}
          {diaData.map(b => {
            const cat = CATS[b.cat] || CATS.personalizado;
            return (
              <div key={b.id} onClick={()=>toggleHecho(b.id)}
                style={{background:"white", borderRadius:14, padding:"14px 16px", marginBottom:10, display:"flex", alignItems:"center", gap:12, cursor:"pointer", boxShadow:"0 2px 6px rgba(0,0,0,0.06)", opacity:b.hecho?0.6:1, borderLeft:`4px solid ${cat.color}`, transition:"opacity 0.2s"}}>
                <div style={{width:28, height:28, borderRadius:14, border:`2px solid ${cat.color}`, display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0, background:b.hecho?cat.color:"transparent", transition:"background 0.2s"}}>
                  {b.hecho && <span style={{color:"white", fontSize:14, fontWeight:700}}>✓</span>}
                </div>
                <div style={{flex:1, minWidth:0}}>
                  <div style={{fontWeight:600, fontSize:15, color:b.hecho?"#AAA":"#222", textDecoration:b.hecho?"line-through":"none", overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap"}}>{b.titulo}</div>
                  <div style={{fontSize:12, color:"#888", marginTop:2}}>{b.inicio} – {b.fin} · <span style={{color:cat.color, fontWeight:600}}>{cat.nombre}</span></div>
                </div>
              </div>
            );
          })}

          <button onClick={()=>{ setModal(true); setModalError(""); }}
            style={{width:"100%", padding:"14px", background:BRAND, color:"white", border:"none", borderRadius:14, fontSize:15, fontWeight:700, cursor:"pointer", marginTop:4, boxShadow:`0 4px 12px ${BRAND}44`, display:"flex", alignItems:"center", justifyContent:"center", gap:8}}>
            <span style={{fontSize:20}}>+</span> Agregar actividad
          </button>
        </div>

        {/* Modal agregar actividad */}
        {modal && (
          <div style={{position:"fixed", inset:0, background:"rgba(0,0,0,0.5)", display:"flex", alignItems:"flex-end", justifyContent:"center", zIndex:100}}>
            <div style={{background:"white", borderRadius:"24px 24px 0 0", padding:"24px 20px 32px", width:"100%", maxWidth:520, boxSizing:"border-box"}}>
              <div style={{fontWeight:700, fontSize:18, color:"#222", marginBottom:18}}>Nueva actividad</div>
              <label style={{fontSize:13, color:"#555", fontWeight:600}}>Nombre</label>
              <input value={nuevoBloque.titulo} onChange={e=>setNuevoBloque({...nuevoBloque,titulo:e.target.value})}
                placeholder="Ej: Reunión con cliente, Ir al médico..."
                style={{width:"100%", padding:"12px", borderRadius:10, border:"1.5px solid #ddd", fontSize:15, marginTop:4, marginBottom:14, boxSizing:"border-box", outline:"none"}}/>
              <div style={{display:"grid", gridTemplateColumns:"1fr 1fr", gap:12, marginBottom:14}}>
                <div>
                  <label style={{fontSize:13, color:"#555", fontWeight:600}}>Inicio</label>
                  <input type="time" value={nuevoBloque.inicio} onChange={e=>setNuevoBloque({...nuevoBloque,inicio:e.target.value})}
                    style={{width:"100%", padding:"12px", borderRadius:10, border:"1.5px solid #ddd", fontSize:15, marginTop:4, boxSizing:"border-box"}}/>
                </div>
                <div>
                  <label style={{fontSize:13, color:"#555", fontWeight:600}}>Fin</label>
                  <input type="time" value={nuevoBloque.fin} onChange={e=>setNuevoBloque({...nuevoBloque,fin:e.target.value})}
                    style={{width:"100%", padding:"12px", borderRadius:10, border:"1.5px solid #ddd", fontSize:15, marginTop:4, boxSizing:"border-box"}}/>
                </div>
              </div>
              <label style={{fontSize:13, color:"#555", fontWeight:600}}>Categoría</label>
              <div style={{display:"grid", gridTemplateColumns:"1fr 1fr", gap:8, marginTop:6, marginBottom:16}}>
                {Object.entries(CATS).map(([k,v])=>(
                  <button key={k} onClick={()=>setNuevoBloque({...nuevoBloque,cat:k})}
                    style={{padding:"8px 10px", borderRadius:8, border:`2px solid ${nuevoBloque.cat===k?v.color:"#ddd"}`, background:nuevoBloque.cat===k?v.bg:"white", color:v.color, fontWeight:600, fontSize:13, cursor:"pointer", textAlign:"left"}}>
                    {v.nombre}
                  </button>
                ))}
              </div>
              {modalError && <div style={{color:"#C00", fontSize:13, marginBottom:12, padding:"8px 12px", background:"#FDE8E8", borderRadius:8}}>{modalError}</div>}
              <div style={{display:"flex", gap:10}}>
                <button onClick={()=>{ setModal(false); setModalError(""); }} style={{flex:1, padding:"13px", borderRadius:12, border:"1.5px solid #ddd", background:"white", fontWeight:600, cursor:"pointer", fontSize:15}}>Cancelar</button>
                <button onClick={agregarBloque} style={{flex:1, padding:"13px", borderRadius:12, border:"none", background:BRAND, color:"white", fontWeight:700, cursor:"pointer", fontSize:15}}>Agregar</button>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  // ════════════════════════════════════════════════════════
  // PANTALLA: EDITAR RUTINA
  // ════════════════════════════════════════════════════════
  if (pantalla==="rutina") {
    const lista = tabRutina==="semana" ? plantilla.semana() : plantilla.finde();

    return (
      <div style={{minHeight:"100vh", background:"#F0F4F8", fontFamily:"Arial, sans-serif", paddingBottom:40}}>
        <div style={headerStyle}>
          <div style={{padding:"20px 16px 12px"}}>
            <button onClick={()=>setPantalla("dia")} style={{background:"rgba(255,255,255,0.18)", border:"none", color:"white", borderRadius:8, padding:"7px 12px", cursor:"pointer", fontSize:13, marginBottom:12}}>← Volver al día</button>
            <div style={{color:"white", fontWeight:700, fontSize:19}}>⚙ Rutina base</div>
            <div style={{color:"rgba(255,255,255,0.7)", fontSize:13}}>Perfil: {perfil.nombre}</div>
            <div style={{display:"flex", gap:8, marginTop:12}}>
              {["semana","finde"].map(t=>(
                <button key={t} onClick={()=>setTabRutina(t)}
                  style={{flex:1, padding:"8px", borderRadius:10, border:"none", background:tabRutina===t?"white":"rgba(255,255,255,0.18)", color:tabRutina===t?BRAND:"white", fontWeight:700, fontSize:14, cursor:"pointer"}}>
                  {t==="semana"?"📅 Semana":"🏖 Fin de semana"}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div style={{padding:"14px 14px", maxWidth:520, margin:"0 auto"}}>
          <div style={{background:"#EBF3FA", borderRadius:12, padding:"10px 14px", marginBottom:14}}>
            <span style={{color:BRAND_MID, fontSize:13}}>ℹ Esta es la plantilla base. Los cambios aquí se reflejan en días nuevos.</span>
          </div>

          {lista.map((b,i) => {
            const cat = CATS[b.cat] || CATS.personalizado;
            return (
              <div key={i} style={{background:"white", borderRadius:14, padding:"14px 16px", marginBottom:10, display:"flex", alignItems:"center", gap:12, boxShadow:"0 2px 6px rgba(0,0,0,0.06)", borderLeft:`4px solid ${cat.color}`}}>
                <div style={{flex:1}}>
                  <div style={{fontWeight:600, fontSize:15, color:"#222"}}>{b.titulo}</div>
                  <div style={{fontSize:12, color:"#888", marginTop:2}}>{b.inicio} – {b.fin} · <span style={{color:cat.color, fontWeight:600}}>{cat.nombre}</span></div>
                </div>
              </div>
            );
          })}

          <div style={{background:"#EBF3FA", borderRadius:14, padding:16, marginTop:8}}>
            <div style={{fontWeight:700, color:BRAND, marginBottom:12, fontSize:15}}>+ Agregar a la plantilla</div>
            <input value={nuevoBloque.titulo} onChange={e=>setNuevoBloque({...nuevoBloque,titulo:e.target.value})}
              placeholder="Nombre de la actividad"
              style={{width:"100%", padding:"10px 12px", borderRadius:10, border:"1.5px solid #B0C8E0", fontSize:14, marginBottom:10, boxSizing:"border-box"}}/>
            <div style={{display:"grid", gridTemplateColumns:"1fr 1fr", gap:8, marginBottom:10}}>
              <input type="time" value={nuevoBloque.inicio} onChange={e=>setNuevoBloque({...nuevoBloque,inicio:e.target.value})}
                style={{padding:"10px", borderRadius:10, border:"1.5px solid #B0C8E0", fontSize:14, boxSizing:"border-box"}}/>
              <input type="time" value={nuevoBloque.fin} onChange={e=>setNuevoBloque({...nuevoBloque,fin:e.target.value})}
                style={{padding:"10px", borderRadius:10, border:"1.5px solid #B0C8E0", fontSize:14, boxSizing:"border-box"}}/>
            </div>
            <select value={nuevoBloque.cat} onChange={e=>setNuevoBloque({...nuevoBloque,cat:e.target.value})}
              style={{width:"100%", padding:"10px 12px", borderRadius:10, border:"1.5px solid #B0C8E0", fontSize:14, marginBottom:12, background:"white", boxSizing:"border-box"}}>
              {Object.entries(CATS).map(([k,v])=><option key={k} value={k}>{v.nombre}</option>)}
            </select>
            {modalError && <div style={{color:"#C00", fontSize:13, marginBottom:10, padding:"8px", background:"#FDE8E8", borderRadius:8}}>{modalError}</div>}
            <button onClick={()=>{
              if (!nuevoBloque.titulo.trim()) { setModalError("Escribe un nombre."); return; }
              if (mins(nuevoBloque.inicio)>=mins(nuevoBloque.fin)) { setModalError("Hora de inicio debe ser antes del fin."); return; }
              setNuevoBloque({ titulo:"", inicio:"08:00", fin:"09:00", cat:"trabajo" });
              setModalError("");
              alert("Bloque agregado. En la versión completa se guarda automáticamente.");
            }} style={{width:"100%", padding:"12px", background:BRAND, color:"white", border:"none", borderRadius:10, fontWeight:700, fontSize:15, cursor:"pointer"}}>
              Agregar a la plantilla
            </button>
          </div>
        </div>
      </div>
    );
  }

  return null;
}
