package org.infinispan.creson;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;


/**
 * @author Pierre Sutra
 */

@Target({ElementType.TYPE,ElementType.FIELD})
@Retention(value = RetentionPolicy.RUNTIME)
public @interface Entity {
   String key() default "";
}