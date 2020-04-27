create table categoria (
    "ID" NUMBER,
 "NOMBRE_CATEGORIA" VARCHAR2(50 BYTE),
 "IVA" NUMBER(5,2)) tablespace ts_examen19 pctfree 5;

create table PRODUCTO(
    "CODIGO_BARRAS" NUMBER,
 "OFERTA" NUMBER,
 "DESCRIPCION" VARCHAR2(500 CHAR),
 "STOCK" NUMBER,
 "EXPOSICION" NUMBER,
 "TEMPERATURA" NUMBER,
 "PESO_NETO" NUMBER,
 "CATEGORIA" NUMBER,
 "METROS_LINEALES" NUMBER,
 "PRECIO_ACTUAL" NUMBER(6,2),
 "PASILLO" NUMBER
) tablespace ts_examen19 pctfree 15;

alter table categoria add constraint pk_categoria primary key (id);
alter table producto add constraint pk_producto primary key (codigo_barras);
alter table producto add constraint fk_producto_cat foreign key (categoria) references categoria;

create bitmap index idx_prod_cat on producto(categoria);
create index idx_cat_des on producto(upper(descripcion));
create index idx_cat_precio on producto(precio_actual);
create unique index idx_cat_nom on categoria(nombre_categoria);

grant select on categoria to r_corrige;
grant update(nombre_categoria) on categoria to r_corrige;
create view v_producto as select codigo_barras, descripcion,categoria, precio_actual from producto;
grant select on v_producto to r_corrige;
create synonym category for categoria;
create synonym product  for producto;


select * from user_users;

insert into esc.mi_respuesta values (1,'31/03/20');
show sga
insert into esc.mi_respuesta values (2, 218103808);
select blocks from v$datafile where name like '%examenes.dbf';
insert into esc.mi_respuesta values (3, 64000);
select bytes from v$log where status='CURRENT';
insert into esc.mi_respuesta values (4, 52428800);

(SELECT sy.privilege FROM user_SYS_privs sy UNION
SELECT rosy.privilege FROM role_sys_privs rosy inner join user_role_privs rp on rosy.role=rp.granted_role) order by 1;
insert into esc.mi_respuesta values (5, 'CREATE JOB');
commit;

/***********************************************************************************/

create materialized view vm_producto refresh force next sysdate + 1/24
as select "CODIGO_BARRAS",
 "DESCRIPCION",
 "STOCK",
 "NOMBRE_CATEGORIA",
 PRECIO_ACTUAL + (PRECIO_ACTUAL*IVA/100) "PVP" from producto join categoria on categoria =id

