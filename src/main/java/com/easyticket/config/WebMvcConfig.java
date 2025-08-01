package com.easyticket.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.ViewResolver;
import org.springframework.web.servlet.config.annotation.*;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

import java.util.Locale;

/**
 * Web MVC 配置
 *
 * @author hxp
 * @version 1.0.0
 */
@Configuration
@EnableWebMvc
public class WebMvcConfig implements WebMvcConfigurer {

    /**
     * JSP视图解析器
     */
    @Bean
    public ViewResolver viewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setViewClass(JstlView.class);
        resolver.setPrefix("/WEB-INF/jsp/");
        resolver.setSuffix(".jsp");
        resolver.setExposeContextBeansAsAttributes(true);
        return resolver;
    }

    /**
     * 国际化配置 - 语言解析器
     */
    @Bean
    public LocaleResolver localeResolver() {
        SessionLocaleResolver slr = new SessionLocaleResolver();
        slr.setDefaultLocale(Locale.ENGLISH); // 默认英文
        return slr;
    }

    /**
     * 国际化配置 - 语言切换拦截器
     */
    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor lci = new LocaleChangeInterceptor();
        lci.setParamName("lang"); // 通过URL参数切换语言，如 ?lang=zh_CN
        return lci;
    }

    /**
     * 注册拦截器
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor())
                .addPathPatterns("/**") // 拦截所有路径
                .excludePathPatterns("/static/**"); // 排除静态资源
    }

    /**
     * 配置静态资源处理
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // LayUI静态资源
        registry.addResourceHandler("/layui/**")
                .addResourceLocations("classpath:/static/layui/");

        // CSS样式文件
        registry.addResourceHandler("/css/**")
                .addResourceLocations("classpath:/static/css/");

        // JavaScript文件
        registry.addResourceHandler("/js/**")
                .addResourceLocations("classpath:/static/js/");

        // 图片资源
        registry.addResourceHandler("/images/**")
                .addResourceLocations("classpath:/static/images/");

        // PDF发票文件
        registry.addResourceHandler("/invoices/**")
                .addResourceLocations("file:invoices/");

        // 通用静态资源
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
    }

    /**
     * 简单页面控制器映射
     */
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 首页重定向到登录页面
        registry.addViewController("/").setViewName("redirect:/login");

        // 错误页面
        registry.addViewController("/error/403").setViewName("error/403");
        registry.addViewController("/error/404").setViewName("error/404");
        registry.addViewController("/error/500").setViewName("error/500");
    }
}