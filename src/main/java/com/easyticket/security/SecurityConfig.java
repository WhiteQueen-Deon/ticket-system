package com.easyticket.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.session.HttpSessionEventPublisher;
import org.springframework.security.crypto.password.PasswordEncoder;
/**
 * Spring Security 安全配置
 *
 * @author hxp
 * @version 1.0.0
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 暴露AuthenticationManager bean
     */
    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    /**
     * 会话事件发布器
     */
    @Bean
    public HttpSessionEventPublisher httpSessionEventPublisher() {
        return new HttpSessionEventPublisher();
    }

    /**
     * 配置认证管理器
     */
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userDetailsService)
            .passwordEncoder(passwordEncoder);
    }

    /**
     * HTTP安全配置
     */
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            // 授权配置
            .authorizeRequests()
                // 静态资源允许访问
                .antMatchers("/static/**", "/css/**", "/js/**", "/images/**", "/layui/**").permitAll()
                // 公共页面允许访问
                .antMatchers("/", "/login", "/register", "/perform-register", "/activate", "/forgot-password", "/reset-password").permitAll()
                // 验证码接口允许访问
                .antMatchers("/captcha").permitAll()
                // REST API 接口允许访问（演示用）
                .antMatchers("/api/**").permitAll()
                // 管理员专用页面
                .antMatchers("/admin/**").hasRole("ADMIN")
                // 经理和管理员可访问管理页面
                .antMatchers("/manage/**").hasAnyRole("ADMIN", "MANAGER")
                // 其他所有请求需要认证
                .anyRequest().authenticated()
            .and()

            // 登录配置
            .formLogin()
                .loginPage("/login")
                .loginProcessingUrl("/perform-login")
                .usernameParameter("username")
                .passwordParameter("password")
                .defaultSuccessUrl("/", true)
                .failureUrl("/login?error")
                .permitAll()
            .and()

            // 登出配置
            .logout()
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            .and()

            // 会话管理
            .sessionManagement()
                .maximumSessions(1)
                .maxSessionsPreventsLogin(false)
                .sessionRegistry(sessionRegistry())
                .and()
            .and()

            // CSRF保护（对于JSP页面保持开启）
            .csrf()
                .ignoringAntMatchers("/api/**")
            .and()

            // 异常处理
            .exceptionHandling()
                .accessDeniedPage("/error/403")
            .and()

            // 安全头
            .headers()
                .frameOptions().deny()
                .contentTypeOptions().and()
                .httpStrictTransportSecurity(hstsConfig -> hstsConfig
                    .maxAgeInSeconds(31536000)
                    .includeSubDomains(true))
            .and()

            // 禁用X-Frame-Options对某些页面
            .headers().frameOptions().sameOrigin();
    }

    /**
     * 会话注册表
     */
    @Bean
    public org.springframework.security.core.session.SessionRegistry sessionRegistry() {
        return new org.springframework.security.core.session.SessionRegistryImpl();
    }
}
