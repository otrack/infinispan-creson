package org.infinispan.creson;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

/**
 * @author Pierre Sutra
*/
@Aspect
public class Distribution {

   @Pointcut("call((@org.infinispan.creson.Entity *).new(..)) " +
         "&& ! within(org.infinispan.creson.container.BaseContainer)" +
         "&& ! within(org.infinispan.creson.filter.ObjectFilterConverter)")
   public static void initEntityClass(ProceedingJoinPoint pjp) {
   }

   @Pointcut("set(@org.infinispan.creson.Entity * *) ")
   public static void setEntityField(ProceedingJoinPoint pjp) {
   }

   @Around("initEntityClass(pjp)")
   public Object distributionAdviceClass(ProceedingJoinPoint pjp) throws Throwable{
      Factory factory = Factory.getSingleton();
      return factory.getInstanceOf(
            pjp.getStaticPart().getSignature().getDeclaringType(),
            null,
            true,
            false,
            pjp.getArgs());
   }

   @Around("setEntityField(pjp)")
   public void distributionAdviceField(ProceedingJoinPoint pjp) throws Throwable{
      Factory factory = Factory.getSingleton();
      String fieldName = pjp.getStaticPart().getSignature().getName();
      Field field = pjp.getStaticPart().getSignature().getDeclaringType().getField(fieldName);
      if (Modifier.isPublic(field.getModifiers()) && Modifier.isStatic(field.getModifiers())) {
         String key = field.getAnnotation(Entity.class).key();
         field.set(pjp.getTarget(), factory.getInstanceOf(pjp.getArgs()[0].getClass(), key, true, false));
         return;
      }
      throw new IllegalStateException("Entity fields for "+pjp.getTarget().getClass()+" must be both public and static.");
   }

}